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
    # Amazon Linux 2023 packages PostgreSQL with versioned names (postgresql15-*).
    if [[ "$OS_ID" == "amzn" && "$OS_VERSION_ID" =~ ^2023 ]]; then
        sudo yum install -y postgresql15-server postgresql15 postgresql15-contrib
    else
        sudo yum install -y postgresql-server postgresql-contrib
    fi
    if command -v postgresql-setup >/dev/null 2>&1; then
        if postgresql-setup --help 2>&1 | grep -q -- '--initdb'; then
            if ! sudo postgresql-setup --initdb --unit postgresql; then
                sudo postgresql-setup --initdb
            fi
        else
            sudo postgresql-setup initdb
        fi
    fi
fi

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

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
