#!/bin/bash
#author: muou
#version: 0.7
#date: 2023-11-16
#update:2023-11-21

function create_db_t1(){
	read -p "请输入你的数据库使用名：" mysql_user
	read -p "请输入 $mysql_user 的密码：" mysql_password

	echo "请稍等~"
	#数据库的信息
	#---------------------#
	MYSQL_USER=$mysql_user
	MYSQL_PASSWORD=$mysql_password
	#---------------------#
	select_db_t1
}

function select_db_t1(){
    read -p "是否需要创造新的库表【y/n】：" true1
    if [[ $true1 == y ]];then
        read -p "请输入 用于功能的数据库名：" mysql_db
        read -p "请输入 用于功能的数据库表名：" mysql_t1
        MYSQL_DB=$mysql_db
        MYSQL_TABLE=$mysql_t1
        mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE $MYSQL_DB;" 
        mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -e "CREATE TABLE $MYSQL_TABLE(username VARCHAR(20) UNIQUE,password VARCHAR(30));" 
        mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -e "INSERT INTO $MYSQL_TABLE VALUES('zhangsan','123456');" 
        echo "已存在一个用户 zhangsan 密码为 123456 "
    else
        read -p "请输入已存在的数据库名：" mysql_db
        read -p "请输入已存在的数据库表名：" mysql_t1
        MYSQL_DB=$mysql_db
        MYSQL_TABLE=$mysql_t1

        mysqldb=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW CREATE DATABASE $MYSQL_DB ;")
        
        if [ -n "$mysqldb" ]; then
            echo "已查询到数据库！"
            wait
            
            mysqltable=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -e "SHOW CREATE TABLE $MYSQL_TABLE ;")
            if [ -n "$mysqltable" ];then
                echo "已查询到数据库中的表！"
                wait
            else
                echo "输入的数据库表不存在！"
                wait
                select_db_t1
            fi
        else
            echo "输入的数据库不存在！"
            wait
            select_db_t1
        fi
    fi
}




function wait() {
    read -p "请按任意键继续" key
}

function menu() {
echo "========================================================="
echo "|   __  _____  ______  __  ____________  ____  __   ____|"
echo "|  /  |/  / / / / __ \/ / / /_  __/ __ \/ __ \/ /  / __/|"
echo "| / /|_/ / /_/ / /_/ / /_/ / / / / /_/ / /_/ / /___\ \  |"
echo "|/_/  /_/\____/\____/\____/ /_/  \____/\____/____/___/  |"
echo "|                                                       |"
echo "========================================================="
echo "------------------------TOOLS----------------------------"
echo "1.用户登录注册"
echo "2.未开发功能——"
echo "3.退出脚本"
echo "------------------------TOOLS----------------------------"
read -p "请输入你要使用功能的序号：" choose1
    case $choose1 in
        1) menu_user ;;
        2) menu ;;
        3) exit 1 ;;
        *) echo "无效选项，请重新输入！" ; wait ; menu ;;
    esac
}

function menu_user() {
    echo "
-------------USERS-------------
1.用户登录
2.用户注册
3.修改密码
4.返回
5.退出工具箱
-------------USERS-------------
"
read -p "请输入你要对用户执行的操作：" choose1_1
    case $choose1_1 in
        1) menu_login ;;
        2) menu_register ;;
        3) menu_change_password ;;
        4) menu ;;
        5) exit 1 ;;
        *) echo "无效选项，请重新输入！" ; wait ; menu_user ;;
    esac
}

function menu_login() {
    echo "------------|LOGON|------------"
    read -p "请输入登录的用户名：" username
    read -p "请输入用户 $username 的密码：" password

    credentials_valid=$(mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -se "SELECT username, password FROM $MYSQL_TABLE WHERE username='$username' AND password='$password';" )

    if [ -n "$credentials_valid" ]; then
        echo "登录成功，欢迎 $username！"
        wait
        lamp1
    else
        echo "登录失败，用户名或密码错误。"
        wait
    fi
    menu_user
}

function menu_register() {
    echo "-----------|SIGN_UP|-----------"
    read -p "请输入注册的用户名：" username
    read -p "请输入注册用户 $username 的密码：" password

    user_exists=$(mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -se "SELECT username FROM $MYSQL_TABLE WHERE username='$username';"  )

    if [ -z "$user_exists" ]; then
        if [[ $password =~ [[:alnum:]] && $password =~ [[:lower:]] && $password =~ [[:upper:]] &&  ${#password} -ge 8 && ${#password} -le 16 ]];then
            
            mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -e "INSERT INTO $MYSQL_TABLE (username, password) VALUES ('$username', '$password');" 
        
            echo "用户 $username 已成功注册。"
            wait
        else
            echo "你的密码太简单，请重新注册"
            wait
        fi
    else
        echo "用户名 $username 已存在，请选择其他用户名。"
        wait
    fi
    menu_user
}

function menu_change_password() {
    echo "-----------|CHANGE|-----------"
    read -p "请输入登录的用户名：" username
    read -p "请输入$username 当前的密码：" current_password

    credentials_valid=$(mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -se "SELECT EXISTS(SELECT 1 FROM $MYSQL_TABLE WHERE username='$username' AND password='$current_password')") 

    if [ "$credentials_valid" -eq 1 ]; then
        read -p "请输入新密码: " new_password
        if [[ $new_password =~ [[:alnum:]] && $new_password =~ [[:lower:]] && $new_password =~ [[:upper:]]  && ${#new_password} -ge 8 && ${#new_password} -le 16 ]];then
            mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB -e "UPDATE $MYSQL_TABLE SET password='$new_password' WHERE username='$username';" 
            echo "密码已更新成功。"
            wait
        else
            echo "你的新密码太简单，请稍后再试！"
            wait
        fi
    else
        echo "密码输入错误"
        wait
    fi
    menu_user
}

function lamp(){
wget -O "/root/lamp.sh" "https://bk.muou.online/up/lamp.sh" --no-check-certificate -T 30 -t 5 -d
chmod -x "/root/lamp.sh"
chmod 777 "/root/lamp.sh"
echo "下载完成"
echo "输入 bash /root/lamp.sh 来执行"
bash "/root/lamp.sh"
}

function lamp1(){
    bash <(curl -sSL https://bk.muou.online/up/lamp.sh)

}

create_db_t1

menu
