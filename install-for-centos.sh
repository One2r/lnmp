#!/bin/bash
echo "============================1.安装前相关工作=================================="

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo 'LANG="en_US.UTF-8"' > /etc/sysconfig/i18n

###设置dns
cat >>/etc/resolv.conf<<eof
nameserver 222.246.129.80
nameserver 59.51.78.210
eof

###设置时区
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yum install -y ntp
ntpdate -u pool.ntp.org
date

###安装fastestmirror插件
yum -y install yum-fastestmirror
yum -y update

#Disable SeLinux
if [ -s /etc/selinux/config ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

cp /etc/yum.conf /etc/yum.conf.lnmp
sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

###安装相关lib
for packages in patch make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap lrzsz screen rsync;
do yum -y install $packages; done

tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14/
./configure
make && make install
cd ../

tar zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
cd ../

tar zxvf pcre-8.33.tar.gz
cd pcre-8.33/
./configure
make && make install
cd ../

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

ldconfig

tar zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install
cd ../

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi

ldconfig

cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

#内核参数调整
cat >>/etc/sysctl.conf<<eof
fs.file-max=65535
eof

###移除系统自带la(n)mp包
rpm -qa|grep httpd
rpm -e httpd
rpm -qa|grep mysql
rpm -e mysql
rpm -qa|grep php
rpm -e php
###删除系统默认安装la(n)mp
yum -y remove httpd*
yum -y remove php*
yum -y remove mysql-server mysql
yum -y remove php-mysql
yum -y remove httpd

echo "============================2.安装lnmp=================================="

echo "==========MariaDB=========="
cat >>/etc/yum.repos.d/MariaDB.repo<<eof
# MariaDB 10.0 CentOS repository list - created 2013-08-23 13:08 UTC 
# http://mariadb.org/mariadb/repositories/ 
[mariadb] 
name = MariaDB 
baseurl = http://yum.mariadb.org/10.0/centos6-amd64 
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB 
gpgcheck=1
eof

yum -y update

yum -y install MariaDB-client MariaDB-server MariaDB-devel

service mysql start

mysqladmin -u root password 'root'

echo "==========MariaDB install completed=========="

echo "==========PHP=========="

tar zxvf php-5.6.25.tar.gz
cd php-5.6.25/
./configure  \
--prefix=/usr/local/php-5.6.25 \
--with-config-file-path=/usr/local/php-5.6.25/etc \
--enable-fpm \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--disable-fileinfo \
--enable-opcache

make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
rm -f /usr/bin/phpize
rm -f /usr/bin/php-config

ln -s /usr/local/php-5.6.25 /usr/local/php	
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/bin/php-config /usr/bin/php-config

mkdir -p /usr/local/php-5.6.25/etc
cp php.ini-production /usr/local/php-5.6.25/etc/php.ini
mv /usr/local/php-5.6.25/etc/php-fpm.conf.default /usr/local/php-5.6.25/etc/php-fpm.conf

cd ..

echo "==========PHP install completed=========="

echo "==========Nginx=========="
tar zxvf nginx-1.10.1.tar.gz
cd nginx-1.10.1/
./configure --prefix=/usr/local/nginx-1.10.1

make && make install
rm -f /usr/bin/nginx
ln -s /usr/local/nginx-1.10.1 /usr/local/nginx
ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

cd .. 
echo "==========Nginx install completed=========="

echo "============================3.安装后相关工作=================================="

#添加www www用户及相应目录
groupadd www
useradd -s /sbin/nologin -g www www
mkdir -p /data/www
mkdir -p /data/logs
chown www:www /data/www -R
chmod 0777 /data/logs -R

#开机启动服务
echo "ntpdate -u pool.ntp.org" >> /etc/rc.local