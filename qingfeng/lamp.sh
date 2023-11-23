#/bin/bash
#本脚本用于lamp安装
caidan(){
cat << EOF
================菜单=============
||      一键编译安装lamp        ||
||      1.安装官方mysql         ||
||      2.安装apache            ||
||      3.安装php               ||
||      4.编译安装MySQL         ||
||      5.编译安装NGINX         ||
||      6.一键配置主从复制      ||
||      7.退出                  ||
=================================
EOF

read -p "请输入你需要的选项：" num
case $num in
	1)
	MYSQL1_INSTALL
	;;
	2)
	APACHE_INSTALL
	;;
	3)
	PHP_INSTALL
	;;
	4)
	MySQL_INSTALL
	;;
	5)
	NGINX_INSTALL
	;;
	6)
	COPY_INSTALL
	;;
	7)
	go_out
	;;
esac
}

MYSQL1_INSTALL(){
	# 清理缓存
	yum -y update;yum clean all;yum makscache
	# 下载epel源
	wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo
	# 下载官方myslq
	rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm
	# 设置5.7版本
	sed -i '5s/enabled=0/enabled=1/'  /etc/yum.repos.d/mysql-community.repo
	sed -i '6s/gpgcheck=1/gpgcheck=0/'  /etc/yum.repos.d/mysql-community.repo
	sed -i '14s/enabled=1/enabled=0/'  /etc/yum.repos.d/mysql-community.repo
	sed -i '15s/gpgcheck=1/gpgcheck=0/'  /etc/yum.repos.d/mysql-community.repo
	# 下载mysql社区版
	yum -y install mysql-community-server
	# 启动mysql服务
	systemctl start mysqld
	systemctl enable mysqld
	# 定义MySQL密码变量
	Mysql_Pass=Qianfeng@123
	# 获取mysql初始密码并更改密码
	temp_password=$(sudo cat /var/log/mysqld.log | grep 'temporary password' | awk '{print $NF}')
mysql -uroot -p"${temp_password}" --connect-expired-password <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY "${Mysql_Pass}";
FLUSH PRIVILEGES;
EOF
# 重启mysql服务
systemctl restart mysqld 
}

APACHE_INSTALL(){
yum -y install httpd
systemctl start httpd
}

PHP_INSTALL(){
yum -y install php
}

MySQL_INSTALL(){
# 清理环境
yum erase mariadb mariadb-server mariadb-libs mariadb-devel -y
userdel -r mysql
rm -rf /etc/my*
rm -rf /var/lib/mysql
# 创建MySQL用户
useradd -r mysql -M -s /sbin/nologin
# -M指定不安装家目录
# 安装编译工具，以及依赖软件
yum -y install ncurses ncurses-devel openssl-devel bison gcc gcc-c++ make cmake
# 创建mysql目录
mkdir -p /usr/local/{data,mysql,log}
# 官方下载MySQL的boost包
wget https://mirrors.aliyun.com/mysql/MySQL-5.7/mysql-boost-5.7.36.tar.gz?spm=a2c6h.25603864.0.0.b21f63aftvppVw

cp mysql-boost-5.7.36.tar.gz?spm=a2c6h.25603864.0.0.b21f63aftvppVw mysql-boost-5.7.36.tar.gz
# 解压下载的软件包
tar zxvf mysql-boost-5.7.36.tar.gz -C /usr/local/
# 切换目录
cd /usr/local/mysql-5.7.36/
# 编译安装
cmake . \
-DWITH_BOOST=boost/boost_1_59_0/ \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DSYSCONFDIR=/etc \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DINSTALL_MANDIR=/usr/share/man \
-DMYSQL_TCP_PORT=3306 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_READLINE=1 \
-DWITH_SSL=system \
-DWITH_EMBEDDED_SERVER=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1
# 编译安装
make -j2 && make -j2 install
# -j2是指定2核
#如果安装出错，想重新安装：不用重新解压，只需要删除安装目录中的缓存文件
# 进入安装目录修改权限
chown -R mysql.mysql .
# 初始化
./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data    
# 初始化,只需要初始化一次，初始化完成之后，一定要记住提示最后的密码用于登陆或者修改密码
# 添加配置文件,删除旧配置文件之后，再添加如下内容
cat >> /etc/my.cnf << EOF
[mysqld]hz9y_JqkOdu*
basedir=/usr/local/mysql       #指定安装目录
datadir=/usr/local/mysql/data  #指定数据存放目录
EOF
# 启动
cd /usr/local/mysql
./bin/mysqld_safe --user=mysql &
# 登录测试
# /usr/local/mysql/bin/mysql -uroot -p'GP9TKGgY9i/8'
#如果需要重新初始化...
# killall mysqld
# rm -rf /usr/local/mysql/data
# bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
}

NGINX_INSTALL(){
# 下载wget
yum -y install wget
# 下载官方nginx
wget https://nginx.org/download/nginx-1.24.0.tar.gz
# 解压nginx包
tar zxvf nginx-1.24.0.tar.gz -C /usr/local/
# 安装nginx所需要的依赖软件
yum -y install gcc gcc-c++ pcre pcre-devel gd-devel openssl-devel  zlib zlib-devel
# 创建nginx用户，不允许登录
useradd nginx -s /sbin/nologin
# 切换目录
cd nginx-1.24.0
# 配置安装参数
./configure --prefix=/usr/local/nginx \
--group=nginx \
--user=nginx \
--sbin-path=/usr/local/nginx/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf
#过程当中如果出错，删除Makefile文件后重新配置
# 编译以及编译安装
make && make install
# 启动服务，切换到--sbin-path指定的目录，运行nginx可以执行程序，启动./nginx
cd --sbin-path;./nginx
}

COPY_INSTALL(){
master=ip1
slave=ip2
read -p "请输入master的IP地址：" IP1
read -p "请输入slave的IP地址：" IP2
# 关闭防火墙
systemctl stop firewalld;setenforce 0
# 域名解析
cat >> /etc/hosts << EOF
$IP1 master
$IP2 slave
EOF
# ping下网络
ping slave &> /dev/null
if [ $? -eq 0 ];then
	echo "网络正常，可以使用"
else
	echo "sorry 网络不通"
fi
# 添加主机配置
cat >> /etc/my.cnf << EOF
log-bin=/var/lib/mysql/master
server-id=1
gtid_mode=ON
enforce_gtid_consistency=1
EOF
# 主机授权
grant replication slave,super,reload on *.* to slave@'%' identified by 'Qianfeng123!';
# 刷新权限
flush privileges;
# 此项为互为主从配置
change master to master_host='slave',master_user='slave',master_password='1',master_auto_position=1;
# 启动slave服务
start slave;
# 查看服务状态，是否有error
show slave status\G
}

go_out(){
break
	echo "再见！！！"
}

caidan 




