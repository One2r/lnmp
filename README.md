# lnmp
A shell of lnmp(CentOS + Nginx/OpenResty + MariaDB + PHP) for my development environment.  
个人开发环境搭建脚本。目前仅做个人开发环境和学习使用，线上环境，请谨慎使用！

# 安装
    git clone git@github.com:One2r/lnmp.git lnmp
	cd lnmp
	git checkout xxx
    chmod +x install-for-centos.sh 
	./install-for-centos.sh
lnmp目录结构如下：  
 .  
 ├── install-for-centos.sh  
 ├── LICENSE  
 ├── lnmp.conf  
 ├── main.sh  
 └── README.md   
	
PHP、Nginx/OpenResty源码将下载至根目录，各源码包版本配置详见lnmp.conf文件。

# 鸣谢
LNMP一键安装包([http://www.lnmp.org/](http://www.lnmp.org/ "http://www.lnmp.org/"))是一款非常优秀的软件，本人在开发lnmp环境搭建脚本的过程中向它学习借鉴了很多。

# 许可
Licensed under the MIT license
