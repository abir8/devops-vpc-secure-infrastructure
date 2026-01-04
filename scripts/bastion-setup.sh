#!/bin/bash

# ============================================
# Bastion Host Setup Script
# Author: Ashraf Hossain Khan
# Purpose: Secure Bastion Host for DevOps VPC
# ============================================

set -e

echo "[INFO] Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "[INFO] Installing essential packages..."
sudo apt-get install -y \
  curl \
  wget \
  unzip \
  git \
  htop \
  jq \
  net-tools \
  fail2ban

echo "[INFO] Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

echo "[INFO] Hardening SSH configuration..."

sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

sudo systemctl restart ssh

echo "[INFO] Configuring Fail2Ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "[INFO] Enabling firewall rules..."
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "[INFO] Creating DevOps user..."
sudo useradd -m -s /bin/bash devops
sudo mkdir -p /home/devops/.ssh
sudo chmod 700 /home/devops/.ssh

echo "[INFO] Bastion host setup completed successfully."
