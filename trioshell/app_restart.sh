#!/bin/bash


nginxbinpath="$HOME/app/nginx/sbin/nginx"
phpbinpath="$HOME/app/php/sbin/php-fpm"
zkbinpath="$HOME/app/zookeeper/bin/zkServer.sh"
redisbinpath="$HOME/app/redis/bin/redis-server"
esbinpath="$HOME/app/elasticsearch/bin/elasticsearch"
mqbinpath="$HOME/app/apache-activemq/bin/activemq"
fileupdatebinpath="$HOME/FileUpdate/shell/all.sh"
inotifybinpath="$HOME/service"
apimonitorbinpath="$HOME/trio/apimonitor"
mysqlbinpath="$HOME/app/mysql/bin"

function nginx_restart(){
    echo "nginx restart"
    cd ${nginxbinpath%%nginx}
    ./nginx -s stop -p $HOME/app/nginx
    sleep 0.5
    ./nginx -p $HOME/app/nginx

}

function php_restart(){
    echo "php restart"
    cd ${phpbinpath%%php-fpm}
    pkill -f php-fpm
    sleep 0.5
    ./php-fpm -p $HOME/app/php -c $HOME/app/php/lib/php.ini
}

function es_restart(){
    echo "elasticsearch restart"
    cd ${esbinpath%%elasticsearch}
    pkill -f elasticsearch
    export ES_HEAP_SIZE=4g
    ./elasticsearch -d -p $HOME/app/elasticsearch/es.pid
}

function redis_restart(){
    echo "redis restart"
    cd ${redisbinpath%%redis-server}
    pid=`cat ../redis.pid`
    kill -9 $pid
    ./redis-server ../etc/redis.conf 
}

function zk_restart(){
    echo "zookeeper restart"
    cd ${zkbinpath%%zkServer.sh}
    ./zkServer.sh stop
    ./zkServer.sh start
}

function mq_restart(){
    echo "activemq restart"
    cd ${mqbinpath%%activemq}
    ./activemq stop
    ./activemq start
}

function fileupdate_restart(){
#    pkill -f ./all.sh
    pkill -f run.entities.sh
    pkill -f run.intent.sh
    pkill -f run.newstock.sh
    pkill -f run.stnames.sh
    pkill -f run.suspendnames.sh
    cd ${fileupdatebinpath%%all.sh}
    /bin/bash ./all.sh &
}

function inotify_restart(){
    pkill -f watch_and_sync.sh
    pkill -f dir_monitor.sh
    cd $inotifybinpath
    nohup sh dir_monitor.sh prod_data &> 1.log &
    nohup sh watch_and_sync.sh prod_data &> 2.log &
}

function apimonitor_restart(){
    pkill -f apimonitor_run.sh
    pkill -f apimonitor.sh
    cd $apimonitorbinpath
    /bin/bash ./runapimonitor.sh &
}

function mysql_restart(){
    if [ -d $mysqlbinpath ];then
        cd $mysqlbinpath
        ./mysql.server stop
        ./mysql.server start
    fi
}

function all_restart(){
    nginx_restart
    php_restart
    es_restart
    mq_restart
    redis_restart
    zk_restart
#    mysql_restart
#    fileupdate_restart
#    inotify_restart
#    apimonitor_restart
}

if [[ "$#" != 1 ]];then
    echo "usage: $0 [all_restart|nginx_restart|php_restart|es_restart|mq_restart|redis_restart|zk_restart|fileupdate_restart|apimonitor_restart|inotify_restart|mysql_restart]"
else
    $1
fi
