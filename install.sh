#!/bin/bash

# Exit script on any error
set -e

# Update package list and install dependencies
echo "Updating package list and installing dependencies..."
sudo yum update -y
sudo yum install -y yum-utils curl

# Install Docker
echo "Installing Docker..."
if ! command -v docker &> /dev/null
then
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo "Docker installed successfully. You may need to log out and back in for Docker permissions to take effect."
else
    echo "Docker is already installed."
fi

# Check Docker permissions
if ! docker info &> /dev/null; then
    echo "Docker permissions are not yet active. Please log out and log back in, or restart your session, and re-run this script if needed."
    exit 1
else
    echo "Docker permissions verified."
fi

# Install Minikube
echo "Installing Minikube..."
if ! command -v minikube &> /dev/null
then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    echo "Minikube installed successfully."
else
    echo "Minikube is already installed."
fi

# Install kubectl
echo "Installing kubectl..."
if ! command -v kubectl &> /dev/null
then
    curl -LO "https://dl.k8s.io/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "kubectl installed successfully."
else
    echo "kubectl is already installed."
fi

# Start Minikube with resource constraints
echo "Starting Minikube..."
minikube start --driver=docker --cpus=2 --memory=2048
