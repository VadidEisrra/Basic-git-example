#! /bin/bash
yum update -y
yum install -y git
yum install -y httpd
cd /var/www
git clone https://github.com/gabrielecirulli/2048.git
sed -i 's+/var/www/html+/var/www/2048+g' /etc/httpd/conf/httpd.conf
systemctl start httpd && systemctl enable httpd
