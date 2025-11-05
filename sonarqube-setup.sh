#!/bin/bash

# SonarQube Installation Script for EC2 (Amazon Linux 2/Ubuntu)
# This script installs and configures SonarQube Community Edition

set -e

echo "=========================================="
echo "SonarQube Installation Script"
echo "=========================================="

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    OS_ID=${ID:-}
    OS_VERSION_ID=${VERSION_ID:-}
fi

PG_SERVICE="postgresql"
POSTGRESQL_SETUP_BIN=""

echo "Detected OS: $OS"

# Update system
echo "Updating system packages..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt-get update
    sudo apt-get upgrade -y
elif [[ "$OS" == *"Amazon"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum update -y
fi

# Install Java 17 (required for SonarQube 10.x)
echo "Installing Java 17..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt-get install -y openjdk-17-jdk
elif [[ "$OS" == *"Amazon"* ]]; then
    sudo yum install -y java-17-amazon-corretto-devel
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum install -y java-17-openjdk-devel
fi

# Verify Java installation
java -version

# Set system limits for SonarQube
echo "Configuring system limits..."
sudo bash -c 'cat >> /etc/sysctl.conf << EOF
vm.max_map_count=524288
fs.file-max=131072
EOF'

sudo bash -c 'cat >> /etc/security/limits.conf << EOF
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOF'

sudo sysctl -p

# Create SonarQube user
echo "Creating SonarQube user..."
sudo useradd -M -d /opt/sonarqube -s /bin/bash sonarqube || true

# Download and install SonarQube
SONAR_VERSION="10.3.0.82913"
echo "Downloading SonarQube ${SONAR_VERSION}..."
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip

# Install unzip if not present
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt-get install -y unzip
elif [[ "$OS" == *"Amazon"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum install -y unzip
fi

# Extract SonarQube
echo "Extracting SonarQube..."
sudo unzip sonarqube-${SONAR_VERSION}.zip
sudo mv sonarqube-${SONAR_VERSION} sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Configure SonarQube
echo "Configuring SonarQube..."
sudo bash -c 'cat > /opt/sonarqube/conf/sonar.properties << EOF
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOF'

# Create systemd service
echo "Creating systemd service..."
sudo bash -c 'cat > /etc/systemd/system/sonarqube.service << EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOF'

# Install and configure PostgreSQL
echo "Installing PostgreSQL..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt-get install -y postgresql postgresql-contrib
elif [[ "$OS" == *"Amazon"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    if sudo yum install -y postgresql-server postgresql-contrib; then
        PG_SERVICE="postgresql"
    else
        echo "Default PostgreSQL package not found. Trying versioned packages..."
        if sudo yum install -y postgresql15-server postgresql15 postgresql15-contrib; then
            PG_SERVICE="postgresql-15"
            if [[ -x /usr/pgsql-15/bin/postgresql-setup ]]; then
                POSTGRESQL_SETUP_BIN="/usr/pgsql-15/bin/postgresql-setup"
            fi
        else
            echo "Failed to install PostgreSQL packages." >&2
            exit 1
        fi
    fi

    if [[ -z "$POSTGRESQL_SETUP_BIN" ]]; then
        if command -v postgresql-setup >/dev/null 2>&1; then
            POSTGRESQL_SETUP_BIN="$(command -v postgresql-setup)"
        else
            SETUP_CANDIDATE=$(ls /usr/pgsql-*/bin/postgresql-setup 2>/dev/null | head -n 1 || true)
            if [[ -n "$SETUP_CANDIDATE" ]]; then
                POSTGRESQL_SETUP_BIN="$SETUP_CANDIDATE"
            fi
        fi
    fi

    if [[ -n "$POSTGRESQL_SETUP_BIN" ]]; then
        if sudo "$POSTGRESQL_SETUP_BIN" --help 2>&1 | grep -q -- '--initdb'; then
            if ! sudo "$POSTGRESQL_SETUP_BIN" --initdb --unit "$PG_SERVICE"; then
                sudo "$POSTGRESQL_SETUP_BIN" --initdb
            fi
        else
            sudo "$POSTGRESQL_SETUP_BIN" initdb
        fi
    fi
fi

# Start PostgreSQL
sudo systemctl start "$PG_SERVICE"
sudo systemctl enable "$PG_SERVICE"

# Create SonarQube database
echo "Creating SonarQube database..."
sudo -u postgres psql << EOF
CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
\q
EOF

# Start SonarQube
echo "Starting SonarQube service..."
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

echo "=========================================="
echo "SonarQube installation completed!"
echo "Please wait 2-3 minutes for SonarQube to start"
echo "Access SonarQube at: http://<your-ec2-public-ip>:9000"
echo "Default credentials: admin/admin"
echo "=========================================="
echo ""
echo "Check status with: sudo systemctl status sonarqube"
echo "View logs with: sudo tail -f /opt/sonarqube/logs/sonar.log"
