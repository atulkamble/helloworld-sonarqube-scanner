#!/bin/bash

# SonarScanner Installation Script
# This script installs SonarScanner CLI for code analysis

set -e

echo "=========================================="
echo "SonarScanner Installation Script"
echo "=========================================="

# SonarScanner version
SCANNER_VERSION="5.0.1.3006"

# Download SonarScanner
echo "Downloading SonarScanner ${SCANNER_VERSION}..."
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SCANNER_VERSION}-linux.zip

# Extract SonarScanner
echo "Extracting SonarScanner..."
unzip sonar-scanner-cli-${SCANNER_VERSION}-linux.zip
sudo mv sonar-scanner-${SCANNER_VERSION}-linux /opt/sonar-scanner

# Add to PATH
echo "Configuring PATH..."
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile.d/sonar-scanner.sh
source /etc/profile.d/sonar-scanner.sh

# Verify installation
echo ""
echo "=========================================="
echo "SonarScanner installed successfully!"
echo "=========================================="
sonar-scanner --version

echo ""
echo "To use sonar-scanner in current session, run:"
echo "export PATH=\$PATH:/opt/sonar-scanner/bin"
