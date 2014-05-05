#!/bin/bash
#2012-10-17
#By Wangrui
#Script name deploy.sh
#Discribe: deploy single code files automatically and restart Tomcat Server
#version 1.1 
code_path=/home/wangrui/update
sudo updatedb
#backup
sudo /bin/cp -r /data/webroot/tms/ /data/backup/tms/tms_bak_`date +%Y%m%d-%H%M`
#deploy code
cd $code_path
for code in `ls .`
do 
	for aim in `locate $code |grep "/data/webroot/tms/" |grep "/${code}"`
	do
  	locate $code |grep "/data/webroot/tms/" |grep "/${code}" >/dev/null
	if [ $? == 0 ]; then
		sudo /bin/cp -f $code $aim
	else 
		echo "${code} not found in project files"
	fi
	done
done
echo "code deploy ok ,please restart tomcat"
rm -f $code_path/*

#restart tomcat
java_pid=$(ps axu | grep '/usr/local/tomcat/conf/logging.properties' | grep -v grep | awk  '{print $2}')
read -p "Do you want to restart the tomcat server([Y|N],Default:Y)" commit
case "$commit" in
        ""|Y|y)
        echo "############# Now, Restart tomcat server...."
        kill -9 $java_pid
        rm -rf /usr/local/tomcat/work/Catalina/localhost/*
        /usr/local/tomcat/bin/catalina.sh start
        [ $? -eq 0 ] && echo -e '\033[32;49;1m Tomcat server restart succeed!\033[39;49;0m'
        ;;
        N|n)
        exit 0
esac
sleep 2
#重启建班服务
/data/webroot/tms/ClassServer.sh stop
/data/webroot/tms/ClassServer.sh start

sleep 3

tail -f /usr/local/tomcat/logs/catalina.out
