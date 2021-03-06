#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the docker-mono-aspnet web server stack
# ------------------------------------------------------------------------------

apt-get update

# ------------------------------------------------------------------------------
# unzip
# ------------------------------------------------------------------------------

apt-get -y install unzip

# ------------------------------------------------------------------------------
# curl
# ------------------------------------------------------------------------------

apt-get -y install curl libcurl3 libcurl3-dev

# ------------------------------------------------------------------------------
# Supervisor
# ------------------------------------------------------------------------------

apt-get -y install python # Install python (required for Supervisor)

mkdir -p /etc/supervisord/
mkdir /var/log/supervisord

# copy all conf files
cp /provision/conf/supervisor.conf /etc/supervisord.conf
cp /provision/service/* /etc/supervisord/

curl https://bootstrap.pypa.io/ez_setup.py -o - | python

easy_install supervisor

# ------------------------------------------------------------------------------
# SSH
# ------------------------------------------------------------------------------

apt-get -y install openssh-server
mkdir /var/run/sshd
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

#keys
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chown root:root /root/.ssh
cp /provision/keys/insecure_key.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# ------------------------------------------------------------------------------
# cron
# ------------------------------------------------------------------------------

apt-get -y install cron

# ------------------------------------------------------------------------------
# nano
# ------------------------------------------------------------------------------

apt-get -y install nano

# ------------------------------------------------------------------------------
# NGINX web server
# ------------------------------------------------------------------------------

# install nginx
apt-get -y install nginx

# copy a development-only default site configuration
cp /provision/conf/nginx-development /etc/nginx/sites-available/default
cp /provision/conf/fastcgi_params /etc/nginx/fastcgi_params

# disable 'daemonize' in nginx (because we use supervisor instead)
echo "daemon off;" >> /etc/nginx/nginx.conf

# ------------------------------------------------------------------------------
# Mono and ASP.NET
# ------------------------------------------------------------------------------

apt-get -y install mono-complete
apt-get -y install mono-xps4
apt-get -y install mono-fastcgi-server4

# ------------------------------------------------------------------------------
# MariaDB server
# ------------------------------------------------------------------------------

# install MariaDB client and server
apt-get -y install mariadb-client
apt-get -y install mariadb-server pwgen

# copy MariaDB configuration
cp /provision/conf/my.cnf /etc/mysql/my.cnf

# MariaDB seems to have problems starting if these permissions are not set:
mkdir /var/run/mysqld
chmod 777 /var/run/mysqld

# ------------------------------------------------------------------------------
# MySQL Connector∕Net
#
# http://www.mono-project.com/docs/database-access/providers/mysql
# http://dev.mysql.com/doc/connector-net/en/connector-net-installation-unix.html
# https://www.linode.com/docs/websites/frameworks/build-aspnetmono-applications-with-modmono-and-apache-on-debian-5-lenny
# ------------------------------------------------------------------------------

cd /opt/
#wget http://dev.mysql.com/get/Downloads/Connector-Net/mysql-connector-net-6.9.8-noinstall.zip
curl -sL -o ./mysql-connector.zip http://dev.mysql.com/get/Downloads/Connector-Net/mysql-connector-net-6.9.8-noinstall.zip
unzip -d mysqlConnector mysql-connector.zip
cd mysqlConnector/v4.5/
gacutil /i MySql.Data.dll
gacutil /i MySql.Web.dll 

# ------------------------------------------------------------------------------
# Node and npm
# ------------------------------------------------------------------------------

curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
sudo apt-get install -y nodejs

# ------------------------------------------------------------------------------
# Git version control
# ------------------------------------------------------------------------------

# install git
apt-get -y install git

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------
rm -rf /provision