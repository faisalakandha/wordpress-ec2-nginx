# wordpress-ec2-nginx
Wordpress Setup Script on aws ec2 using NGINX, MariaDB, Ubuntu

Helpful Notes:

### Change the following directory on Ubuntu to change upload_max_filesize
/etc/php/7.4/fpm/php.ini 

### Go to /etc/nginx/nginx.conf 
in the http block paste the following: client_max_body_size 100M;

