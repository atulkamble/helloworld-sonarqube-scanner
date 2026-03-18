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
