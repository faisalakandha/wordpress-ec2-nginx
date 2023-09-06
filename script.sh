#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found."
  exit 1
fi

# Update and install required packages
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php7.4 nginx mariadb-server php7.4-fpm php7.4-mysql

# Download and configure WordPress
sudo mkdir -p /var/www
cd /var/www
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rm latest.tar.gz
sudo chown -R www-data:www-data wordpress
sudo find wordpress/ -type d -exec chmod 755 {} \;
sudo find wordpress/ -type f -exec chmod 644 {} \;

# Secure MySQL installation and create WordPress database
echo "Configuring MySQL..."
sudo mysql_secure_installation
sudo mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME default character set utf8 collate utf8_unicode_ci;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Create Nginx config for WordPress
echo "Configuring Nginx..."
cat <<EOF | sudo tee /etc/nginx/sites-available/wordpress.conf > /dev/null
upstream php-handler {
    server unix:/var/run/php/php7.4-fpm.sock;
}
server {
    listen 80;
    server_name $DOMAIN_NAME;
    root /var/www/wordpress;
    index index.php;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass php-handler;
    }
}
EOF

# Enable Nginx site and test configuration
sudo ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Install additional PHP extensions
sudo apt install -y php7.4-curl php7.4-dom php7.4-mbstring php7.4-imagick php7.4-zip php7.4-gd

# Install Certbot for SSL
sudo apt install -y snapd
sudo snap install core; snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Configure SSL certificate
sudo certbot --nginx

echo "WordPress installation completed successfully!"
