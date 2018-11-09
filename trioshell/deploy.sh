#!/bin/bash
case $1 in
1)
tar zxf app.tgz
tar zxf mysql.tgz
tar zxf TrioPortal.tgz
unzip EsFaq.zip
unzip shell.zip
unzip TrioApi.zip
rm -rf *.zip *.tgz
mv TrioPortal TrioApi
mv mysql app
sed -i 's/192.168.26.88/127.0.0.1/' $HOME/TrioApi/TrioBrain/index.php
;;
2)
#mysql config
$HOME/app/mysql/bin/mysqld --defaults-file=$HOME/app/mysql/my.cnf --initialize-insecure --basedir=$HOME/app/mysql --datadir=$HOME/app/mysql/data
$HOME/app/mysql/bin/mysql.server start
$HOME/app/mysql/bin/mysql --defaults-file=$HOME/app/mysql/my.cnf -uroot -e "create database faq;"
$HOME/app/mysql/bin/mysql --defaults-file=$HOME/app/mysql/my.cnf -uroot faq < $HOME/TrioApi/TrioPortal/test.sql
$HOME/app/mysql/bin/mysql --defaults-file=$HOME/app/mysql/my.cnf -uroot -e "grant all privileges on *.* to root@'%' identified by "triotest";"
$HOME/app/mysql/bin/mysql --defaults-file=$HOME/app/mysql/my.cnf -uroot -e "flush privileges;"
;;
esac