#!/bin/bash

# Script to analyze all applications with SonarQube
# Prerequisites: SonarQube server running, SonarScanner installed

set -e

echo "=========================================="
echo "Running SonarQube Analysis"
echo "=========================================="

# Check if SONAR_HOST_URL is set
if [ -z "$SONAR_HOST_URL" ]; then
    echo "WARNING: SONAR_HOST_URL not set. Using default: http://localhost:9000"
    SONAR_HOST_URL="http://localhost:9000"
fi

# Check if SONAR_TOKEN is set
if [ -z "$SONAR_TOKEN" ]; then
    echo "WARNING: SONAR_TOKEN not set. You may need to provide authentication."
    SONAR_AUTH=""
else
    SONAR_AUTH="-Dsonar.login=$SONAR_TOKEN"
fi

echo "SonarQube Server: $SONAR_HOST_URL"
echo ""

# Analyze Python application
echo "=========================================="
echo "Analyzing Python Application"
echo "=========================================="
cd python-app
if [ -f "requirements.txt" ]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt || true
fi

echo "Running Python tests..."
pytest --cov=. --cov-report=xml:coverage.xml || true

cd ..
sonar-scanner \
    -Dsonar.projectKey=helloworld-python \
    -Dsonar.projectName="Hello World Python" \
    -Dsonar.sources=python-app \
    -Dsonar.python.coverage.reportPaths=python-app/coverage.xml \
    -Dsonar.host.url=$SONAR_HOST_URL \
    $SONAR_AUTH

echo ""

# Analyze Java application
echo "=========================================="
echo "Analyzing Java Application"
echo "=========================================="
cd java-app
if command -v mvn &> /dev/null; then
    echo "Running Maven build and tests..."
    mvn clean verify sonar:sonar \
        -Dsonar.host.url=$SONAR_HOST_URL \
        $SONAR_AUTH || true
else
    echo "Maven not found. Skipping Java analysis."
fi
cd ..

echo ""

# Analyze Node.js application
echo "=========================================="
echo "Analyzing Node.js Application"
echo "=========================================="
cd nodejs-app
if command -v npm &> /dev/null; then
    echo "Installing Node.js dependencies..."
    npm install
    
    echo "Running Node.js tests with coverage..."
    npm run test:coverage || true
fi

cd ..
sonar-scanner \
    -Dsonar.projectKey=helloworld-nodejs \
    -Dsonar.projectName="Hello World Node.js" \
    -Dsonar.sources=nodejs-app \
    -Dsonar.exclusions=nodejs-app/node_modules/**,nodejs-app/coverage/** \
    -Dsonar.javascript.lcov.reportPaths=nodejs-app/coverage/lcov.info \
    -Dsonar.host.url=$SONAR_HOST_URL \
    $SONAR_AUTH

echo ""
echo "=========================================="
echo "Analysis Complete!"
echo "=========================================="
echo "View results at: $SONAR_HOST_URL"
