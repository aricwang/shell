#!/bin/bash
# Filename: jurenlong_fabu.sh
# Date: 2014-03-19
# Version: 0.1

# Date: 2014-04-16
# Version: 1.0
# Update Info: 新增发布日志

fabuo_log=/data/temp/jurenlong_fabu.log
fabu_time=`date +%Y-%m-%d/%H:%M:%S`

#[ -e $fabu_log ] && /bin/mv $fabu_log ${fabu_log}.bak_$fabu_time

# 1. 上传代码到jurenlong,210.51.161.184/210.51.161.137服务器
echo "$fabu_time start fabu Jurenlong TMS" 
/bin/sh /data/release/rsync_jurenlong.sh  
sleep 5
echo "---------------------------------------------------------------\n" 

# 2. 210.51.161.184发布代码
salt yz.online.app.jurenlong.184.juren.com cmd.run '/bin/sh /data/release/release_use_salt.sh -y' 
echo "---------------------------------------------------------------\n" 
sleep 5

# 3. 210.51.161.137发布代码
salt yz.online.app.jurenlong.137.juren.com cmd.run '/bin/sh /data/release/release_use_salt.sh -y' 
echo "---------------------------------------------------------------\n" 
sleep 68

# 4. 检查发布结果
echo "172.16.1.184 check_tms:\n" 
/usr/local/nagios/libexec/check_http -H localhost -I 172.16.1.184 -u http://tms.jurenlong.com/tologin.shtml -p 80 -s "用户名" 
echo "---------------------------------------------------------------\n" 

echo "172.16.1.137 check_tms:\n" 
/usr/local/nagios/libexec/check_http -H localhost -I 172.16.1.137 -u http://tms.jurenlong.com/tologin.shtml -p 80 -s "用户名" 
echo "$fabu_time Jurenlong TMS fabu finished " 
