#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
NAME_BIN="rclone"
### BEGIN INIT INFO
# Provides:          rclone
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start rclone at boot time
# Description:       Enable rclone by daemon.
### END INIT INFO

NAME="aliyunwebdav" #Rclone配置时填写的name
REMOTE=''  #远程文件夹，网盘里的挂载的一个文件夹，留空为整个网盘
LOCAL='/disk/ssda/Public/aliyun'  #挂载地址，VPS本地挂载目录
LOG="/$HOME/.rclone/rcloned.log"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
RETVAL=0


check_local(){
	if [ ! -d "$LOCAL" ]; then
	    echo "The directory $LOCAL does not exist."
	    return 1
	else
		return 0
	fi
}
check_running(){
	PID="$(pidof $NAME_BIN | awk '{print $1}')"
	if [[ ! -z ${PID} ]]; then
		return 0
	else
		return 1
	fi
}
do_start(){
	echo "$NAME_BIN 开始启动"
	sleep 2
	check_local
	if [[ $? -eq 0 ]]; then
		echo "rclone The directory $LOCAL does not exist." && exit 0
	check_running
	if [[ $? -eq 0 ]]; then
		echo -e "${Info} $NAME_BIN (PID ${PID}) 正在运行..." && exit 0
	else
		fusermount -zuq $LOCAL >/dev/null 2>&1
		mkdir -p $LOCAL
		mkdir -p ${LOG%/*}
		rclone mount $NAME:$REMOTE $LOCAL --cache-dir /disk/ssda/Caches/rclone --allow-other --vfs-cache-mode writes --allow-non-empty --read-only --header "Referer:https://www.aliyundrive.com/" > "${LOG}" 2>&1 &
		sleep 2s
		check_running
		if [[ $? -eq 0 ]]; then
			echo -e "${Info} $NAME_BIN 启动成功 !"
		else
			echo -e "${Error} $NAME_BIN 启动失败 !"
		fi
	fi
}
do_stop(){
	check_running
	if [[ $? -eq 0 ]]; then
		kill -9 ${PID}
		RETVAL=$?
		if [[ $RETVAL -eq 0 ]]; then
			echo -e "${Info} $NAME_BIN 停止成功 !"
		else
			echo -e "${Error} $NAME_BIN 停止失败 !"
		fi
	else
		echo -e "${Info} $NAME_BIN 未运行"
		RETVAL=1
	fi
	fusermount -zuq $LOCAL >/dev/null 2>&1
}
do_status(){
	check_running
	if [[ $? -eq 0 ]]; then
		echo -e "${Info} $NAME_BIN (PID $(echo ${PID})) 正在运行..."
	else
		echo -e "${Info} $NAME_BIN 未运行 !"
		RETVAL=1
	fi
}
do_restart(){
	do_stop
	sleep 2s
	do_start
}
case "$1" in
	start|stop|restart|status)
	do_$1
	;;
	*)
	echo "使用方法: $0 { start | stop | restart | status }"
	RETVAL=1
	;;
esac