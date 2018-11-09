#!/bin/bash

user=$1
source /home/$user/.bash_profile
HOME=${HOME:-"/home/$user"}
# crontab -e 
# 编辑 */30 * * * * /bin/bash service_monitor.sh trio 并保存

#服务开关
sw_nginx=1
sw_php=1
sw_zk=1
sw_redis=1
sw_es=1
sw_mq=1
sw_fileupdate=0
sw_inotify=0
sw_apimonitor=0
sw_mysql=0

function start() {
    sw=$1
    name=$2
    pidfile=$3
    if [ $sw_nginx -eq 1 ];then
        pid=`cat $pidfile 2>/dev/null`
        pid=${pid:-needpid}
        np=`ps -ef | grep $pid | grep -v grep | grep -v docker | wc -l`
        if [ $np -gt 0 ];then
           return 0
        fi
        echo $name start
        cd $HOME/shell
        sh app_restart.sh ${name}_restart
        sleep 2
    fi
}

start "$sw_nginx" "nginx" "$HOME/app/nginx/logs/nginx.pid"
start "$sw_php" "php" "$HOME/app/php/var/run/php-fpm.pid"
start "$sw_zk" "zk" "$HOME/app/zookeeper/zookeeper_server.pid"
start "$sw_redis" "redis" "$HOME/app/redis/redis.pid"
start "$sw_es" "es" "$HOME/app/elasticsearch/es.pid"
start "$sw_mq" "mq" "$HOME/app/apache-activemq/data/activemq.pid"
start "$sw_fileupdate" "fileupdate" "$HOME/FileUpdate/shell/run.suspendnames.pid"
start "$sw_inotify" "inotify" "$HOME/service/watch_and_sync.pid"
start "$sw_apimonitor" "apimonitor" "$HOME/trio/apimonitor/apimonitor.pid"
start "$sw_mysql" "mysql"
