#!/bin/bash

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install MySQL
sudo apt install mysql-server -y

# Secure MySQL installation
sudo mysql_secure_installation

# Install PHP and required extensions
sudo apt install php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Configure PHP-FPM
sudo systemctl start php7.4-fpm
sudo systemctl enable php7.4-fpm

# Create a database for WordPress
sudo mysql -u root -p -e "CREATE DATABASE wordpress;"
sudo mysql -u root -p -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"

# Download and configure WordPress
sudo mkdir /var/www/html/wordpress
cd /var/www/html/wordpress
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo cp -r wordpress/* .
sudo rm -rf wordpress latest.tar.gz
sudo chown -R www-data:www-data /var/www/html/wordpress

# Create Nginx virtual host configuration for WordPress
sudo tee /etc/nginx/sites-available/wordpress <<EOF
server {
    listen 80;
    server_name speckbridge.com www.speckbridge.com;
    root /var/www/html/wordpress;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

# Enable the Nginx virtual host configuration
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

# Test Nginx configuration and reload
sudo nginx -t
sudo systemctl reload nginx

echo "WordPress installation completed!"
