#!/bin/bash
set -e

echo "Running post-create setup..."

# Update package lists
sudo apt-get update

# Install additional tools useful for IaC and container management
echo "Installing additional tools..."
sudo apt-get install -y \
    curl \
    wget \
    jq \
    vim \
    htop \
    net-tools \
    iputils-ping \
    dnsutils

# Install podman (for local testing/development)
echo "Installing podman..."
sudo apt-get install -y podman

# Install podman-compose if available
echo "Installing podman-compose..."
pip3 install --user podman-compose || echo "podman-compose installation skipped"

# Install yamllint for YAML validation
echo "Installing yamllint..."
pip3 install --user yamllint

# Clean up
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo "Post-create setup completed!"
echo ""
echo "Available tools:"
echo "  - podman: $(podman --version 2>/dev/null || echo 'not available')"
echo "  - docker: $(docker --version 2>/dev/null || echo 'not available')"
echo "  - git: $(git --version)"
echo "  - yamllint: $(yamllint --version 2>/dev/null || echo 'not available')"
echo ""
echo "You're ready to develop Nextcloud IaC!"
