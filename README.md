# wordpress-ec2-nginx
Wordpress Setup Script on aws ec2 using NGINX, MariaDB, Ubuntu

Helpful Notes:

### Change the following directory on Ubuntu to change upload_max_filesize
/etc/php/7.4/fpm/php.ini 

### Go to /etc/nginx/nginx.conf 
in the http block paste the following: client_max_body_size 100M;

/var/www$ sudo scp -i master-hosting.pem mohakhali.tar.gz ubuntu@3.108.26.97:/home/backups/

mysql -p -u [user] [database] < backup-file.sql

sudo lsof -t -i:3000

tar -czvf file.tar.gz directory

chmod 400 ~/.ssh/ec2private.pem

scp -i pk_dsa.pem linuxhintsignal kali@192.168.1.100:
