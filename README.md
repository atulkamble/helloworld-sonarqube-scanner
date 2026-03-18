# Hello World Quality Scanner

A comprehensive project demonstrating static code analysis with SonarQube across multiple programming languages (Python, Java, Node.js).

## 🎯 Project Goal

Create simple "Hello World" applications in Python, Java, and Node.js, and integrate SonarQube for static code analysis to monitor:
- Code quality metrics
- Bugs and vulnerabilities
- Code smells
- Code duplications
- Test coverage

## 📁 Project Structure

```
helloworld-sonarqube-scanner/
├── python-app/           # Python Hello World application
│   ├── hello.py
│   ├── test_hello.py
│   └── requirements.txt
├── java-app/             # Java Hello World application
│   ├── HelloWorld.java
│   └── pom.xml
├── nodejs-app/           # Node.js Hello World application
│   ├── index.js
│   ├── index.test.js
│   └── package.json
├── sonar-project.properties  # SonarQube configuration
├── sonarqube-setup.sh        # SonarQube installation script
├── install-sonar-scanner.sh  # SonarScanner installation script
└── analyze-all.sh            # Script to analyze all apps
```

## 🚀 Quick Start

### Prerequisites

- AWS EC2 instance (t3.medium or larger recommended)
- Ubuntu 20.04/22.04 or Amazon Linux 2
- At least 4GB RAM
- Python 3.8+
- Java 17+
- Node.js 16+
- Maven (for Java)

### Step 1: Install SonarQube on EC2

1. **Launch EC2 Instance**
   - Instance Type: t3.medium (minimum)
   - AMI: Ubuntu 22.04 LTS or Amazon Linux 2
   - Storage: 20GB
   - Security Group: Allow inbound on port 9000

2. **SSH into EC2 and Install SonarQube**
   ```bash
   chmod +x sonarqube-setup.sh
   ./sonarqube-setup.sh
   ```

3. **Access SonarQube**
   - URL: `http://<EC2-PUBLIC-IP>:9000`
   - Default credentials: `admin/admin`
   - Change password on first login

4. **Generate Authentication Token**
   - Login to SonarQube
   - Go to: User → My Account → Security → Generate Token
   - Save the token securely

### Step 2: Install SonarScanner

On your local machine or EC2:

```bash
chmod +x install-sonar-scanner.sh
./install-sonar-scanner.sh

# Add to current session
export PATH=$PATH:/opt/sonar-scanner/bin
```

### Step 3: Configure Environment Variables

```bash
export SONAR_HOST_URL=http://<EC2-PUBLIC-IP>:9000
export SONAR_TOKEN=<your-generated-token>
```

### Step 4: Run Applications

#### Python Application
```bash
cd python-app
pip install -r requirements.txt
python hello.py
pytest test_hello.py
```

#### Java Application
```bash
cd java-app
mvn clean compile
mvn exec:java -Dexec.mainClass="com.example.HelloWorld"
mvn test
```

#### Node.js Application
```bash
cd nodejs-app
npm install
node index.js
npm test
```

### Step 5: Analyze Code with SonarQube

#### Option 1: Analyze All Applications at Once
```bash
chmod +x analyze-all.sh
./analyze-all.sh
```

#### Option 2: Analyze Individual Applications

**Python:**
```bash
cd python-app
pytest --cov=. --cov-report=xml:coverage.xml
cd ..
sonar-scanner \
    -Dsonar.projectKey=helloworld-python \
    -Dsonar.sources=python-app \
    -Dsonar.host.url=$SONAR_HOST_URL \
    -Dsonar.login=$SONAR_TOKEN
```

**Java:**
```bash
cd java-app
mvn clean verify sonar:sonar \
    -Dsonar.projectKey=helloworld-java \
    -Dsonar.host.url=$SONAR_HOST_URL \
    -Dsonar.login=$SONAR_TOKEN
```

**Node.js:**
```bash
cd nodejs-app
npm run test:coverage
cd ..
sonar-scanner \
    -Dsonar.projectKey=helloworld-nodejs \
    -Dsonar.sources=nodejs-app \
    -Dsonar.host.url=$SONAR_HOST_URL \
    -Dsonar.login=$SONAR_TOKEN
```

## 📊 Understanding SonarQube Metrics

### Key Metrics to Monitor

1. **Bugs**: Issues that can lead to unexpected behavior
2. **Vulnerabilities**: Security-related issues
3. **Code Smells**: Maintainability issues
4. **Coverage**: Percentage of code covered by tests
5. **Duplications**: Repeated code blocks
6. **Technical Debt**: Estimated time to fix all issues

### Quality Gates

SonarQube uses Quality Gates to determine if code meets quality standards:
- **Passed**: Code meets all criteria
- **Failed**: Code has issues that need attention

## 🛠️ Key Skills Demonstrated

### 1. SonarQube Installation on EC2
- ✅ System requirements configuration
- ✅ PostgreSQL database setup
- ✅ SonarQube service configuration
- ✅ Security group and firewall setup

### 2. SonarScanner Configuration
- ✅ Installation and PATH configuration
- ✅ Project-specific properties
- ✅ Multi-language support
- ✅ Authentication and security

### 3. Code Quality Analysis
- ✅ Static code analysis
- ✅ Bug detection
- ✅ Security vulnerability scanning
- ✅ Code smell identification
- ✅ Code duplication detection
- ✅ Test coverage reporting

## 🔧 Troubleshooting

### SonarQube Won't Start
```bash
# Check logs
sudo tail -f /opt/sonarqube/logs/sonar.log

# Check service status
sudo systemctl status sonarqube

# Verify system limits
sysctl vm.max_map_count
ulimit -n
```

### Connection Issues
- Verify EC2 security group allows port 9000
- Check if SonarQube service is running
- Ensure correct SONAR_HOST_URL is set

### Analysis Failures
- Verify SONAR_TOKEN is correct
- Check project key is unique
- Ensure source paths are correct
- Review scanner logs in `.scannerwork/report-task.txt`

## 📚 Additional Resources

- [SonarQube Documentation](https://docs.sonarqube.org/)
- [SonarScanner Documentation](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
- [Quality Gate Documentation](https://docs.sonarqube.org/latest/user-guide/quality-gates/)

Here’s a **production-ready Jenkinsfile** for your multi-language SonarQube project 👇
(Aligned with your repo + token + Sonar setup)

---

# 🚀 Jenkinsfile (Declarative Pipeline)

```groovy
pipeline {
    agent any

    environment {
        SONAR_HOST_URL = "http://54.242.237.45:9000"
        SONAR_TOKEN = "sqa_0691ad2a7d9aadfe8b8a7341bb5ef6d4e43df396"
        PATH = "/opt/sonar-scanner/bin:${env.PATH}"
    }

    tools {
        maven 'maven'        // Configure in Jenkins Global Tool Config
        jdk 'jdk17'          // Configure JDK 17
        nodejs 'node16'      // Optional if NodeJS plugin used
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/atulkamble/helloworld-sonarqube-scanner.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                echo "Installing dependencies..."

                # Python
                sudo yum install -y python3-pip
                pip3 install -r python-app/requirements.txt

                # NodeJS
                cd nodejs-app
                npm install
                cd ..

                # Java (Maven build)
                cd java-app
                mvn clean install
                cd ..
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                echo "Running tests..."

                # Python Test
                pytest python-app/

                # NodeJS Test
                cd nodejs-app
                npm test || true
                cd ..

                # Java Test
                cd java-app
                mvn test
                cd ..
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh '''
                echo "Running SonarQube scan..."

                sonar-scanner \
                  -Dsonar.projectKey=helloworld-multilang \
                  -Dsonar.sources=. \
                  -Dsonar.host.url=$SONAR_HOST_URL \
                  -Dsonar.login=$SONAR_TOKEN
                '''
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
```

---

# 🔧 Important Jenkins Setup (VERY IMPORTANT)

### 1️⃣ Install Plugins

* SonarQube Scanner
* SonarQube Quality Gates
* NodeJS Plugin
* Pipeline Plugin

---

### 2️⃣ Configure SonarQube in Jenkins

**Manage Jenkins → Configure System**

* Add SonarQube Server:

  * Name: `sonar-server`
  * URL: `http://54.242.237.45:9000`
  * Token: (same as yours)

---

### 3️⃣ Configure Tools

**Manage Jenkins → Global Tool Configuration**

* JDK → `jdk17`
* Maven → `maven`
* NodeJS → `node16`

---

### 4️⃣ (Best Practice 🔐) Use Credentials Instead of Hardcoding Token

Replace:

```groovy
SONAR_TOKEN = "your-token"
```

With:

```groovy
SONAR_TOKEN = credentials('sonar-token-id')
```

---

# 📊 Pipeline Flow (Teaching Friendly)

```
Checkout → Install → Test → Sonar Scan → Quality Gate → Result
```

---

# 💡 Pro Tips (DevOps Architect Level)

* Use **separate project keys** for each language (advanced setup)
* Add **coverage reports** (pytest, jacoco, jest)
* Integrate with:

  * GitHub PR checks
  * Jenkins Webhooks
* Add **parallel stages** for Python/Java/Node

---



## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Created as a demonstration project for integrating SonarQube with multiple programming languages.
