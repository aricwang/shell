#!/bin/sh
#
#########################################################
## Description:						#
#	JUREN Information General Backup Script.	#
#  Department: xinxibu					#
#  Writen by: zhangliang				#
#  Date: 2013-06-17					#
#  Version: v2						#
#########################################################

## 定义变量
Date=$(date +"%Y%m%d%H%M")
Ser_IP=`/sbin/ifconfig eth0 | grep inet |awk '{print $2}' |egrep "*[0-9]" |cut -d : -f2`
Remote="172.16.1.148"

BackDir="/data/backup/${Ser_IP}"
mkdir -p ${BackDir}/{App,Sys,Conf,DB} 2>/dev/null

#创建备份日志文件
Applog="${BackDir}/applog.txt"
Conflog="${BackDir}/conflog.txt"
Syslog="${BackDir}/syslog.txt"
[ ! -e $Applog ] && touch $Applog
[ ! -e $Conflog ] && touch $Conflog
[ ! -e $Syslog ] && touch $Syslog

#定义需要备份项
Appdir=(
[0]="/data/webroot/tms/blue_giant"
[1]="/data/webroot/juren_card"
[2]="/data/release")

SysDir=(
[0]="/etc" 
[1]="/root/crontabs"
[2]="/var/spool/cron")

Conf_File=(
[0]="/data/nginx/etc-conf"
[1]="/data/mysql/my*.cnf"
[2]="/usr/local/tomcat/conf"
[3]="/usr/local/php/etc")


#################################################
#                                               #
# 声明备份功能函数:                             #
#  App_bak(),Conf_bak(),Sys_bak(),Db_bak()      #
#                                               #
#################################################

#App备份
function App_bak()
{
	echo -e "\n#------------- `date +"%Y-%m-%d %H:%M"` -----------#" >>$Applog
        echo -e "  @@Starting Backup App Files..." >>$Applog

	cd $BackDir
        cp -rp ${Appdir[0]} App
	cp -rp ${Appdir[1]} App
        if [ "$Ser_IP" == "210.51.161.133" ];then
                cp -rp ${Appdir[2]} App
        fi

        #打包压缩App
	#ls |grep -v ".gz" |xargs /bin/tar -czf App_${Date}.tar.gz
	find App/* -type d -prune |xargs /bin/tar -czf App_${Date}.tar.gz
        mv App_${Date}.tar.gz App

        if [ $? -eq 0 ] && [ -e App/App_${Date}.tar.gz ]
        then
                echo -e "\tLocal Backup Sccuessfully." >>$Applog

                # 删除备份源App下的目录
		DirName=`find App/* -type d -prune`
		if [ ! "$DirName" == "" ];then
                	find App/* -type d -prune |xargs /bin/rm -rf
		else
			continue
		fi
        fi

        #同步App到远程备份服务器
        /usr/bin/rsync -auz ${BackDir}/App/* $Remote::YizhuangIDC_Xinxibu_JAVA/App/Source/${Ser_IP}
        if [ $? -eq 0 ];then
                echo -e "\tRemote Backup Sccuessfully." >>$Applog
        fi
	
	# 删除本地15天前的App备份
	/bin/find ${BackDir}/App -type f -a -name "*.gz" -a -mtime +15 |xargs /bin/rm -f 
}

#Conf备份
function Conf_bak()
{
	echo -e "\n#------------- `date +"%Y-%m-%d %H:%M"` -----------#" >>$Conflog
        echo -e "  @@Starting Backup Configure Files..." >>$Conflog

        cd $BackDir
        [ ! -e Conf/mysql_cnf ] && mkdir Conf/mysql_cnf

        cp -rp ${Conf_File[0]} Conf/nginx_conf
        cp -rp ${Conf_File[1]} Conf/mysql_cnf
        cp -rp ${Conf_File[2]} Conf/tomcat_conf
        cp -rp ${Conf_File[3]} Conf/php_etc

        # 打包压缩Conf
	find Conf/* -type d -prune |xargs /bin/tar -czf Conf_${Date}.tar.gz
        mv Conf_${Date}.tar.gz Conf

        if [ $? -eq 0 ] && [ -e Conf/Conf_${Date}.tar.gz ];then
                echo -e "\tLocal Backup Sccuessfully." >>$Conflog

                #删除备份源Conf下的目录
		DirName=`find Conf/* -type d -prune`
		if [ ! "$DirName" == "" ];then
                	find Conf/* -type d -prune |xargs /bin/rm -rf
		else
			continue
		fi
        fi

        #同步Conf到远程备份服务器
        /usr/bin/rsync -auz ${BackDir}/Conf/* $Remote::YizhuangIDC_Xinxibu_JAVA/App/Conf/${Ser_IP}
        if [ $? -eq 0 ];then
                echo -e "\tRemote Backup Sccuessfully." >>$Conflog
        fi

	# 删除本地15天前的Conf备份
	/bin/find ${BackDir}/Conf -type f -a -name "*.gz" -a -mtime +15 |xargs /bin/rm -f 

}

#Sys备份
function Sys_bak()
{
	echo -e "\n#------------- `date +"%Y-%m-%d %H:%M"` -----------#" >>$Syslog
	echo -e "  @@Starting System Directory Backup..." >>$Syslog

	cd $BackDir
	cp -rp ${SysDir[@]} Sys

	#打包Sys
	find Sys/* -type d -prune |xargs /bin/tar -czf Sys_${Date}.tar.gz &>/dev/null
	mv Sys_${Date}.tar.gz Sys
	
	if [ $? -eq 0 ] && [ -e Sys/Sys_${Date}.tar.gz ];then
                echo -e "\tLocal Backup Sccuessfully." >>$Syslog

                #删除本地备份源Sys下的目录
		DirName=`find Sys/* -type d -prune`
		if [ ! "$DirName" == "" ];then
                	find Sys/* -type d -prune |xargs /bin/rm -rf 
		else
			continue
		fi
                
        fi

	#同步Sys到远程备份服务器
	/usr/bin/rsync -auz ${BackDir}/Sys/* $Remote::YizhuangIDC_Xinxibu_JAVA/Sys/${Ser_IP}
	if [ $? -eq 0 ];then
                echo -e "\tRemote Backup Sccuessfully." >>$Syslog
	fi

	# 删除15天前的Sys备份
	/bin/find ${BackDir}/Sys -type f -a -name "*.gz" -a -mtime +15 |xargs /bin/rm -f 
}

case $1 in
	'app')
		App_bak
	;;
	'conf')
		Conf_bak
	;;
	'sys')
		Sys_bak
	;;
	*)
		echo 'Useage: select backup app|conf|sys'
esac

#任务计划
#------------Backup----------------------#
#App
#0       12,23   */3     *       *       /bin/sh /root/crontabs/backup.sh app

#Conf
#0       12,23   */5     *       *       /bin/sh /root/crontabs/backup.sh conf

#Sys
#0       12,23   */7     *       *       /bin/sh /root/crontabs/backup.sh sys

