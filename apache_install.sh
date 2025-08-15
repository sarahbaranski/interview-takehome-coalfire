#!/bin/bash

# Update package list
sudo apt update

# Install Apache (correct package name on Ubuntu)
sudo apt install -y apache2

# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2
