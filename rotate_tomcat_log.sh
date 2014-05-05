#!/bin/bash
#rotate tomcat's log everyday  by wangrui 2013/09/06
bak_dir=/data/backup/logs/tomcat
log_dir=/usr/local/tomcat/logs
yesterday=`date -d 'yesterday' +%Y%m%d`
date_15=`date -d'15 day ago' +%Y%m%d`
bak_name=catalina.out.${yesterday}

# rotate log
cd  ${log_dir}

cp catalina.out ${bak_name}

echo "" > catalina.out 

# backup log
if [ ! -e ${bak_dir} ]
then
	mkdir ${bak_dir}
fi
mv ${bak_name} ${bak_dir}/

# rm the catalina.out log 15 days ago
cd ${bak_dir}
rm -rf catalina.out.${yesterday}
