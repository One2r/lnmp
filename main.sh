#!/bin/bash

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        wget -c --progress=bar:force ${URL}
    fi
}

Check_Download()
{
    echo "Downloading files..."
    cd lib/
    Download_Files ${Download_Mirror}/web/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz libiconv-${LIBICONV_VERSION}.tar.gz
    Download_Files ${Download_Mirror}/web/libmcrypt/libmcrypt-${LIBMCRYPT_VERSION}.tar.gz libmcrypt-${LIBMCRYPT_VERSION}.tar.gz
    Download_Files ${Download_Mirror}/web/mcrypt/mcrypt-${MCRYPT_VERSION}.tar.gz mcrypt-${MCRYPT_VERSION}.tar.gz
    Download_Files ${Download_Mirror}/web/mhash/mhash-${MHASH_VERSION}.tar.gz mhash-${MHASH_VERSION}.tar.gz
    Download_Files ${Download_Mirror}/web/pcre/pcre-${PCRE_VERSION}.tar.gz pcre-${PCRE_VERSION}.tar.gz
    cd ..
 
    Download_Files ${Download_Mirror}/web/php/php-${PHP_VERSION}.tar.gz php-${PHP_VERSION}.tar.gz
    Download_Files ${Download_Mirror}/web/nginx/nginx-${NGINX_VERSION}.tar.gz nginx-${NGINX_VERSION}.tar.gz
}
