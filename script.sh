#!/bin/sh
# Machine Update
sudo apt upgrade -y
sudo apt update -y
#Installing Essential Requirements
sudo apt install nginx mysql-server php-fpm php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
