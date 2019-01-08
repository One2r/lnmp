#!/bin/bash
echo "============================1.安装前相关工作=================================="
WORKSPACE=`pwd`
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

. lnmp.conf
. main.sh

echo 'LANG="en_US.UTF-8"' > /etc/sysconfig/i18n

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
for packages in epel-release vim wget make cmake gcc gcc-c++ flex bison file libtool libtool-libs kernel-devel libjpeg libjpeg-devel libpng libpng-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel curl curl-devel e2fsprogs e2fsprogs-devel libidn-devel openssl openssl-devel gettext gettext-devel gmp-devel libcap lrzsz ncurses ncurses-devel ntp net-tools systemd-devel;
do yum -y install $packages; done

Check_Download

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

#内核参数调整
cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

cat >>/etc/sysctl.conf<<eof
fs.file-max=65535
eof

###移除系统自带lnmp包
rpm -qa|grep mysql
rpm -e mysql
rpm -qa|grep php
rpm -e php
###删除系统默认安装lnmp
yum -y remove php*
yum -y remove mysql-server mysql
yum -y remove php-mysql

echo "============================2.安装lnmp=================================="

echo "==========MariaDB ${MARIADB_VERSION}=========="
cat >>/etc/yum.repos.d/MariaDB.repo<<eof
# MariaDB ${MARIADB_VERSION} CentOS repository list - created $(date)
# http://mariadb.org/mariadb/repositories/ 
[mariadb] 
name = MariaDB 
baseurl = http://yum.mariadb.org/${MARIADB_VERSION}/centos6-amd64 
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB 
gpgcheck=1
eof

yum -y update

yum -y install MariaDB-client MariaDB-server MariaDB-devel

service mysql start

mysqladmin -u root password 'root'

echo "==========MariaDB install completed=========="

echo "==========PHP ${PHP_VERSION}=========="
cd ${WORKSPACE}
tar -zxvf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}/
./configure  \
--prefix=/usr/local/php-${PHP_VERSION} \
--with-config-file-path=/usr/local/php-${PHP_VERSION}/etc \
--enable-fpm \
--with-fpm-systemd \
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

make -j2
make install

rm -f /usr/bin/php
rm -f /usr/bin/phpize
rm -f /usr/bin/php-config

ln -s /usr/local/php-${PHP_VERSION} /usr/local/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/bin/php-config /usr/bin/php-config

mkdir -p /usr/local/php-${PHP_VERSION}/etc
cp php.ini-production /usr/local/php-${PHP_VERSION}/etc/php.ini
cp /usr/local/php-${PHP_VERSION}/etc/php-fpm.conf.default /usr/local/php-${PHP_VERSION}/etc/php-fpm.conf
cp /usr/local/php-${PHP_VERSION}/etc/php-fpm.d/www.conf.default /usr/local/php-${PHP_VERSION}/etc/php-fpm.d/www.conf

cp ./sapi/fpm/php-fpm.service /usr/lib/systemd/system/
systemctl enable php-fpm
systemctl start php-fpm
cd ..

cp composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer
cp cachetool.phar /usr/local/bin/cachetool && chmod +x /usr/local/bin/cachetool
echo "==========PHP install completed=========="

echo "==========openresty ${OPENRESTY_VERSION}=========="
cd ${WORKSPACE}
tar -zxvf openresty-${OPENRESTY_VERSION}.tar.gz
cd openresty-${OPENRESTY_VERSION}/
./configure --prefix=/usr/local/openresty-${OPENRESTY_VERSION} \
--with-luajit \
--with-stream \
--with-stream_ssl_module \
--with-http_sub_module \
--with-http_stub_status_module \
--with-threads \
--with-openssl

make -j2 && make install
ln -s /usr/local/openresty-${OPENRESTY_VERSION} /usr/local/openresty

/usr/local/openresty/bin/openresty
cd .. 
echo "==========openresty install completed=========="

echo "==========Redis ${REDIS_VERSION}=========="
cd ${WORKSPACE}
tar -zxvf redis-${REDIS_VERSION}.tar.gz
mv redis-${REDIS_VERSION} && cd /usr/local/redis-${REDIS_VERSION}
make -j2 && make install

REDIS_PORT=6379 \
REDIS_CONFIG_FILE=/etc/redis/6379.conf \
REDIS_LOG_FILE=/var/log/redis_6379.log \
REDIS_DATA_DIR=/var/lib/redis/6379 \
REDIS_EXECUTABLE=`command -v redis-server` ./utils/install_server.sh
echo "==========Redis install completed=========="

echo "==========tmux ${TMUX_VERSION}=========="
cd ${WORKSPACE}
tar -xzvf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}
./configure
make && make install
echo "==========tmux install completed=========="

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
chmod +x /etc/rc.local
