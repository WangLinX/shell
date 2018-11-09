#!/bin/bash
#
#使用root修改
#添加/etc/security/limits.conf
#trio - core unlimited
#trio - nofile 288000
#trio - nproc 65536
#trio - memlock unlimited

#es server: echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf
#sysctl -p
#
#mkdir /var/log/usermonitor/#
#HISTORY_FILE=/var/log/usermonitor/usermonitor.log#
#PROMPT_COMMAND='{ date "+%y-%m-%d %T ##### $(who am i |awk "{print \$1\" \"\$2\" \"\$5}")  #### $(history 1 | { read x cmd; echo "$cmd"; })"; #} >>$HISTORY_FILE'
#echo -e "\nexport HISTORY_FILE=/var/log/usermonitor/usermonitor.log
#export PROMPT_COMMAND='$PROMPT_COMMAND'

#" >> /etc/profile
#touch  /var/log/usermonitor/usermonitor.log
#chmod 662 /var/log/usermonitor/usermonitor.log
#
#修改时区
#timedatectl set-local-rtc 1
#timedatectl set-timezone Asia/Shanghai
#timedatectl set-time '2018-09-07 10:19:00'

ip=`ip addr | grep -v docker | grep inet | grep -v inet6 | grep -v 127.0.0.1 | awk '{print $2}' | awk -F'/' '{print $1}' | head -1`
###############################################
# 以下需要手动填写确认
###############################################
# elasticsearch集群 ip 需要手动填写：
es_ip_list=("$ip" "192.168.233.155")
# elasticsearch的watcher topic
es_topic=dfzq
# 恒生FAQ程序 ip list 需要手动填写，多少台faq服务就写多少台ip：
faq_ip_list=("$ip" "192.168.255.155")
# portal用的database信息,没有portal不用改
database_ip=$ip
database_port='3306'
database_name='faq'
database_user='root'
database_password='triotest'
###############################################

cd
echo 'export PATH=$HOME/app/base/jdk1.8.0_144/bin:$HOME/app/base/python/bin:$HOME/app/base/bin:$HOME/app/base/lib2/bin:$HOME/app/mysql/bin:$HOME/app/base/inotify-tools/bin:$PATH
export JAVA_HOME=$HOME/app/base/jdk1.8.0_144
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/app/base/lib2:$HOME/app/base/lib2/lib' >> ~/.bash_profile
source ~/.bash_profile

oldname=trio
oldhome=/home/trio
newname=$USER
newhome=$HOME
mqip=$ip
eshost=\[
for i in ${es_ip_list[@]}
do
    eshost=$eshost\"$i:9405\",
done
eshost=${eshost%,}\]
esnodename=\"chat.cluster.master.${ip##*.}\"


#glances
sed -i "s#${oldhome}#${newhome}#" $HOME/app/base/python/bin/glances
sed -i "s#${oldname}#${newname}#" $HOME/app/base/python/bin/glances

#php
sed -i "s#${oldhome}#${newhome}#" $HOME/app/php/etc/php-fpm.conf
sed -i "s#${oldname}#${newname}#" $HOME/app/php/etc/php-fpm.conf
sed -i "s#${oldhome}#${newhome}#" $HOME/app/php/lib/php.ini
sed -i "s#${oldname}#${newname}#" $HOME/app/php/lib/php.ini

#redis
sed -i "s#${oldhome}#${newhome}#" $HOME/app/redis/etc/redis.conf
sed -i "s#${oldname}#${newname}#" $HOME/app/redis/etc/redis.conf

#es
sed -i "s#node.name: .*#node.name: ${esnodename}#" $HOME/app/elasticsearch/config/elasticsearch.yml
sed -i "s#watcher.activemq.uri: .*#watcher.activemq.uri: ${mqip}#"        $HOME/app/elasticsearch/config/elasticsearch.yml
sed -i "s#watcher.activemq.topic: .*#watcher.activemq.topic: ${es_topic}#"     $HOME/app/elasticsearch/config/elasticsearch.yml
sed -i "s#discovery.zen.ping.unicast.hosts: .*#discovery.zen.ping.unicast.hosts: ${eshost}#"  $HOME/app/elasticsearch/config/elasticsearch.yml

#zookeeper配置
sed -i "s#${oldhome}#${newhome}#" $HOME/app/zookeeper/conf/zoo.cfg
sed -i "s#${oldname}#${newname}#" $HOME/app/zookeeper/conf/zoo.cfg

#nginx
sed -i "s#${oldhome}#${newhome}#" $HOME/app/nginx/conf/nginx.conf
sed -i "s#${oldname}#${newname}#" $HOME/app/nginx/conf/nginx.conf
sed -i "s#${oldhome}#${newhome}#" $HOME/app/nginx/conf/conf.d/*.conf
sed -i "s#${oldname}#${newname}#" $HOME/app/nginx/conf/conf.d/*.conf

#mysql
if [ -d "$newhome/app/mysql" ];then
    cd $newhome/app/mysql/bin
    sed -i "s#$oldhome#$newhome#" mysql.server
    sed -i "s#$oldname#$newname#" mysql.server
    sed -i "s#$oldhome#$newhome#" mysqld_safe
    sed -i "s#$oldname#$newname#" mysqld_safe
    sed -i "s#$oldhome#$newhome#" ../my.cnf
    sed -i "s#$oldname#$newname#" ../my.cnf
fi

# TrioApi
if [ -d "$newhome/TrioApi/wentiguanli" ];then
    cd $newhome/TrioApi/wentiguanli
    for i in `grep '$oldhome' * -r -l `;do sed -i "s#$oldhome#$newhome#" $i ;done
fi

if [ -d "$newhome/TrioApi/TrioBrain" ];then
    cd $newhome/TrioApi/TrioBrain
    for i in `grep '$oldhome' * -r -l `;do sed -i "s#$oldhome#$newhome#" $i ;done
fi

if [ -d "$newhome/TrioApi/TrioPortal" ];then
    cd $newhome/TrioApi/TrioPortal/web/application/
    sed -i "s#[\'\"]CFG_HOST[\'\"].*#'CFG_HOST' => 'http://$ip:9082',#" web/config.php
    sed -i "s#[\'\"]ES_URL[\'\"].*#'ES_URL'=>'http://${es_ip_list[0]}:8405',#" web/config.php
    sed -i "s#[\'\"]FAQ_CONFIG[\'\"].*#'FAQ_CONFIG'=>'http://${es_ip_list[0]}:8405/faq_config',#" web/config.php
    if [ ! -d "$newhome/TrioApi/TrioPortal/web/public/wentiguanli" ];then
        mv $newhome/TrioApi/wentiguanli $newhome/TrioApi/TrioPortal/web/public/
        sed -i "s#[\'\"]QUESTION_API_URL[\'\"].*#'QUESTION_API_URL' => 'http://$ip:9082/wentiguanli/index.php',#" web/config.php
    fi
    sed -i "s#[\'\"]testclick[\'\"].*#'testclick' => 'http://$ip:9082/web/Faqtest/dialog',#" web/config.php
    sed -i "s#'hostname'.*#'hostname'        => '$database_ip',#" database.php
    sed -i "s#'database'.*#'database'        => '$database_name',#" database.php
    sed -i "s#'username'.*#'username'        => '$database_user',#" database.php
    sed -i "s#'password'.*#'password'        => '$database_password',#" database.php
    sed -i "s#'hostport'.*#'hostport'        => '$database_port',#" database.php
    cd $newhome/TrioApi/TrioPortal/
    for i in `grep '$oldhome' * -r -l `;do sed -i "s#$oldhome#$newhome#" $i ;done
fi

# inotify
if [ -d "$newhome/service" ];then
    cd $newhome/service
    inotifyhost="host("
    for i in ${faq_ip_list[@]}
    do
        inotifyhost="$inotifyhost \"$newname@$i:$newhome/service/prod_data\""
    done
    inotifyhost="$inotifyhost )"

    sed -i "/# modify #/,/#############################/{//!d}" watch_and_sync.sh
    sed -i "/# modify #/a LOCAL_HOST=$ip" watch_and_sync.sh
    sed -i "/# modify #/a $inotifyhost" watch_and_sync.sh
fi

#apimonitor
if [ -d "$newhome/trio/apimonitor" ];then
    cd $newhome/trio/apimonitor
    sed -i "s/172.16.2.67/$ip/" apimonitor.sh
fi


echo -e "\033[32m Now do 'source ~/.bash_profile' \033[0m"