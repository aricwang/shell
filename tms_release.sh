#!/bin/bash
# Filename: tms_fabu.sh
# Date: 2014-03-19
# Version: 0.1

# Date: 2014-04-16
# Version: 1.0
# Update Info: 新增发布日志，139启动ClassServer服务

fabuo_log=/data/temp/tms_fabu.log
fabu_time=`date +%Y-%m-%d/%H:%M:%S`

#[ -e $fabu_log] && /bin/mv $fabu_log ${fabu_log}.bak_$fabu_time

# 1. 上传代码到tms,210.51.161.133服务器
echo "$fabu_time start fabu tms" 
/bin/sh /data/release/rsync_tms.sh 
sleep 5
echo "---------------------------------------------------------------\n" 

# 2. 210.51.161.139发布代码
salt yz.online.app.tms.139.juren.com cmd.run '/bin/sh /data/release/release_use_salt.sh -y' 
salt yz.online.app.tms.139.juren.com cmd.run '/webroot/ClassServer.sh stop' 
salt yz.online.app.tms.139.juren.com cmd.run '/webroot/ClassServer.sh start' 
sleep 5
echo "---------------------------------------------------------------\n" 

# 3. 210.51.161.133发布代码
salt yz.online.app.tms.133.juren.com cmd.run '/bin/sh /data/release/release_use_salt.sh -y' 
sleep 60
echo "---------------------------------------------------------------\n" 

# 4. 检查发布结果
echo "172.16.1.139 check_tms:\n" 
/usr/local/nagios/libexec/check_http -H localhost -I 172.16.1.139 -u http://tms.juren.com/tologin.shtml -p 80 -s "用户名" 
echo "---------------------------------------------------------------\n" 

echo "172.16.1.133 check_tms:\n" 
/usr/local/nagios/libexec/check_http -H localhost -I 172.16.1.133 -u http://tms.juren.com/tologin.shtml -p 80 -s "用户名" 

echo "$fabu_time TMS fabu finished " 
