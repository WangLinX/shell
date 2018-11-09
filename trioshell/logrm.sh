#!/bin/bash

home='/home/trio'
eslogpath='/home/trio/app/elasticsearch/bin/log.txt'
nginxlogpath='/home/trio/app/nginx/logs/'
phplogpath='/home/trio/app/php/log'
zklogpath='/home/trio/app/zookeeper/bin/zookeeper.out'


path=(`find $home/trio -type d -name '[lL]og'`)
for i in ${path[@]}
do
    size=`du -b -s $i | awk '{print $1}'`
    if [ $size -gt 10000000000 ];then
        cd $i
        find ./ -name "*log*" -type f -mtime +15 -daystart -exec rm -f {} \;
        find ../[sS]hell -name "core*" -type f -mtime +7 -daystart -exec rm -f {} \;
        find ./ -name "*log*" -type f -size +1G | xargs cp /dev/null 2>/dev/null
    fi
done


essize=`du -b $eslogpath | awk '{print $1}'`
if [ $essize -gt 1000000000 ];then
    echo '' > $espath
fi

find $nginxlogpath -size +1G -type f | xargs cp -f /dev/null 2>/dev/null

find $phplofpath -size +1G -type f | xargs cp -f /dev/null 2>/dev/null

zksize=`du -b $zklogpath | awk '{print $1}'`
if [ $zksize -gt 1000000000 ];then
    echo '' > $espath
fi 
