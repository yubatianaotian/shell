#!/bin/bash


print_logged_in_users(){
who | awk '{print $1}' | sort | uniq

}
get_top_cpu_processes(){
ps -aux --sort=%cpu |head -n11
}
look_cipan(){
df -h

}
ping_network(){
if ping  -c 2 -w 2 www.baidu.com >/dev/null 2>/dev/null
then 
echo "网络可达"
else
echo "网络不可达"
fi
}
selinux()
{
sed -i 's/SELINUX=enforce/SELINUX=disabled/g' /etc/selinux/config

}
chankan(){
read -p "请输入开始时间：" startime
read -p "请输入结束时间：" endtime
starttime=$starttime
endtime=$endtime
sed -n "/$starttime/,/$endtime/p" ip.log |awk '{print $1}' |sort|uniq -c|sort|tail -n 5

}

mem()
{

ps -aux --sort=%mem |head -n11

}
menu(){
while true ;do
	echo  "++++欢迎进入主菜单+++++"
	echo "1) 打印当前系统登录用户  "
	echo "2) 获取系统cpu前十的进程 "
	echo "3) 查看磁盘信息 "
	echo "4)查看网络是否通 "
	echo "5) 退出"
	echo "6)关闭selinux"
	echo "7)查看某个时间段的访问日志,并打印出前五个访问量最高的ip"
	echo "8)查看系统内存前十的进程"
	read -p "请输入选项：" choice
	
	case $choice in
	1)
	print_logged_in_users
	;;
	2)
	get_top_cpu_processes
	;;
	3)
	look_cipan
	;;
	4)
	ping_network
	;;
	5)
	echo "感谢使用，再见"
	exit 0
	;;
	6)
	selinux
	;;
	7)
	chankan	
	;;
	8)
	mem
	;;
	*)
	echo "无效的选择，请重新输入"
	;;
	esac
	read -p "按任意键返回主菜单" any_key
	clear

done
}

menu
