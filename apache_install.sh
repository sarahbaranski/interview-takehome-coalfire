#!/bin/bash

#install apache
sudo apt install -y httpd

#enable and start apache
sudo systemctl enable httpd
sudo systemctl start httpd
