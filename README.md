# lnmp
A shell of lnmp(CentOS + Nginx + MariaDB + PHP) for my development environment.  
个人开发环境搭建脚本。目前仅做个人开发环境和学习使用，线上环境，请谨慎使用！

#安装
    git clone git@github.com:One2r/lnmp.git lnmp
	cd lnmp
	git checkout xxx
    chmod +x install-for-centos.sh 
	./install-for-centos.sh
本脚本所需的源码大多从[http://soft.vpser.net/](http://soft.vpser.net/)获取。安装时，可先将各源码包下载至相应目录。lnmp目录结构如下：

    ├── install-for-centos.sh 
	├── lib 
	|	└── README.md 
	├── lnmp.conf 
	├── main.sh 
	└── README.md
PHP、Nginx源码将下载至根目录，其他依赖lib库源码将下载至lib目录下，各源码包版本配置详见lnmp.conf文件。

#鸣谢
LNMP一键安装包([http://www.lnmp.org/](http://www.lnmp.org/ "http://www.lnmp.org/"))是一款非常优秀的软件，本人在开发lnmp环境搭建脚本的过程中向它学习借鉴了很多。

#许可
Licensed under the MIT license