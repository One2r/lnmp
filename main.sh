#!/bin/bash

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        wget -c --progress=bar:force ${URL} -O ${FileName}
    fi
}

Check_Download()
{
    echo "Downloading files..."
    Download_Files http://au1.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror php-${PHP_VERSION}.tar.gz
    Download_Files https://getcomposer.org/composer.phar composer.phar
    Download_Files http://gordalina.github.io/cachetool/downloads/cachetool.phar cachetool.phar
    Download_Files https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz openresty-${OPENRESTY_VERSION}.tar.gz
    Download_Files http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz redis-${REDIS_VERSION}.tar.gz
		Download_Files https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz tmux-${TMUX_VERSION}.tar.gz
}
