#!/bin/sh
# # Machine Update
# sudo apt upgrade -y
# sudo apt update -y
# #Installing Essential Requirements
# sudo apt install nginx mysql-server php-fpm php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
# #Configuring nginx
# sudo systemctl enable nginx
# sudo systemctl status nginx
# # Path to the sites-available directory
# sites_available_dir="/etc/nginx/sites-available"

# # Name of the configuration file
# config_file="wordpress.conf"

# # Content of the configuration file
# config_content=$(cat << EOF
# server {
#     root /var/www/html/wordpress;
#     index index.php index.html index.htm;
#     server_name example.com www.example.com;

#     client_max_body_size 100M;

#     location / {
#         try_files \$uri \$uri/ /index.php?\$args;
#     }

#     location ~ \.php\$ {
#         include snippets/fastcgi-php.conf;
#         fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
#         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
#     }
# }
# EOF
# )

# # Create the configuration file
# echo "$config_content" | sudo tee "$sites_available_dir/$config_file" > /dev/null

# echo "Created $config_file in $sites_available_dir"

# #Check nginx status
# sudo nginx -t

# Load MYSQL_ROOT_PASSWORD from the .env file
MYSQL_ROOT_PASSWORD=$(grep -oP 'MYSQL_ROOT_PASSWORD=\K.*' .env)

# Check if MYSQL_ROOT_PASSWORD is provided
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "MYSQL_ROOT_PASSWORD not found in .env file!"
  exit 1
fi

# Prepare SQL commands
SQL_COMMANDS=$(cat << EOF
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF
)

# Execute SQL commands using MySQL CLI
echo "$SQL_COMMANDS" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"

echo "MySQL installation secured!"


#Enable MySQL
systemctl start mysql
systemctl enable mysql
