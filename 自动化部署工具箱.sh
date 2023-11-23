#!/bin/bash
#自动化部署一个包含注册、登录，且登录成功后拥有各种功能集一身的工具箱，并使用mysql数据库用于存储用户的各种信息
#2023.11.22
mysql_password="Qianfeng@123"
#创建数据库db1
#mysql -uroot -p$mysql_password -e"create database db1;"
#创建数据库中t1表db1.t1
#mysql -uroot -p$mysql_password -e"create table db1.t1(id varchar(20) primary key not null,password varchar(20) not null);"
#登录函数
log_on(){
	read -p "请输入的你的登录账户： " logon_id
	read -p "请输入的你的登录密码： " login_password
	#查看数据库，确认登录用户是否注册过
	result=$(mysql -uroot -p$mysql_password -e"select * from db1.t1 where name='$logon_id';")
	if [[ $result = "" ]]; then
		echo "没有该用户，请注册!!!"
		continue
	else
		#把输入的用户名和密码与数据库中用户名和密码一一对应，完成确认
		result1=$(mysql -uroot -p$mysql_password -e"select password from db1.t1 where name='$logon_id' and password='$login_password';")
		if [ -n "$result1" ]; then
			fun
		else
			echo "密码错误!!!"
			
			continue
		fi
	fi
}
#登录成功之后有的功能
fun(){
	while true;do
		echo "==================主菜单==================="
		echo "1.打印当前系统登录用户"
		echo "2.检查软件是否安装并打印软件信息"
		echo "3.安装指定软件"
		echo "4.获取系统cpu排名前10的进程"
		echo "5.获取系统内存排名前10的进程"
		echo "6.退出"
		echo "=========================================="

		read -p "请输入你需要的功能: " b 
		case $b in
			1)#打印当前系统登录用户
				whoami
				;;
			2)
				read -p "请输入你需要查询的软件: " c
				#判断软件是否安装
				if command -v $c &> /dev/null;then
					#打印已安装软件的详细信息
					echo "$c已安装"
					rpm -qi $c 
				else 
					echo "$c未安装"
				fi
				;;
			3)
				read -p "请输入你所需要安装的服务: " d 
				#ping百度，检查网络情况
				ping -c1 baidu.com
				if [ $? -eq 0 ]; then
					#通过查找yum源文件，来判断yum源是否可用
					if [ -f /etc/yum.repos.d/CentOS-Base.repo ] && [ -f /etc/yum.repos.d/epel.repo ]; then
						#判断软件是否安装
						if command -v $d &> /dev/null; then
							echo "$d已安装,无需重复安装，谢谢"
							rpm -qi $d 
						else
							yum -y install $d  
							echo "$d安装成功"
						fi
					else
						echo "很抱歉，没有检测到yum源"
						exit 0
					fi
				else
					echo "很抱歉，网络连接失败，请检查网络连接状态"
					exit 0
				fi
				;;
			4)	#提供ps命令来查找cpu排名前10的进程
				ps aux | sort -r -k3 | head -n 10
				;;
			5)	#提供ps命令来查找内存排名前10的进程
				ps aux | sort -r -k4 | head -n 10
				;;
			6)
				echo "感谢使用，再见！"
				continue 3 
				;;
			*)
				echo "请正确输入"
		esac
		echo "===================================================="
		read -p "按回车键返回"
		clear
done
}
#注册函数
register_functions(){
	read -p "请输入你的注册账号： " registered_id
	read -p "请输入你的注册密码： " registered_password
	read -p "请确定你的密码： " next_password
	while true; do
		if [[ $registered_password =~ [A-Z] && $registered_password =~ [a-z] && $registered_password =~ [0-9] && ${#registered_password} -ge 5 ]]; then
			echo "账户名符合要求"
			#提供正则来判断密码是否符合复杂度(至少有8位，同时必须有大小写字母，数字)
			if [[ $registered_password =~ [A-Z] && $registered_password =~ [a-z] && $registered_password =~ [0-9] && $registered_password =~ [^0-z] && ${#registered_password} -ge 8 ]]; then
				echo "密码符合要求"
				#确认密码
				if [ $next_password=$registered_password ]; then
					#去数据库中查找是否有注册用户
					result3=$(mysql -uroot -p$mysql_password -e"select name from db1.t1 where name='$registered_id';")
					if
						[[ $result3 != "" ]]; then
						echo "该账户已经存在，请前往登录"
						continue 2
					else
						#把用户名和密码写入数据库中
						mysql -uroot -p$mysql_password -e"insert into db1.t1(name,password) values('$registered_id','$registered_password');"
						echo "账户创建成功，请前往登录"
						continue 2
					fi
				else
					echo "确认失败，重新输入密码"
					continue 3
				fi
			else
				echo "密码不符合要求，重新输入密码"
				continue 4
			fi
		else
			echo "账户名不符合要求，重新输入账户名"
			continue 5
		fi
	done

}
#工具箱函数
toolbox(){
	while true; do 
	echo "==========主菜单============" 
	echo "1.登录"
	echo "2.注册" 
	echo "3.退出" 
	echo "============================"

	read -p "请输入选项：" number
	case $number in
		1)	#调用登录函数
			log_on
			;;
		2)	#调用注册函数
			register_functions
			;;
		3)
			echo "感谢使用，再见"
				exit 0
			;;
		*)
			echo "请正确输入"
	esac
		echo "==============================="
		read -p "按回车键返回主菜单"
		clear
	done

}
toolbox

