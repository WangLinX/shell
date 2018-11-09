#!/bin/bash
cd $HOME/app/mysql/bin
sed -i "s/trio/$USER/" mysql.server
sed -i "s/trio/$USER/" mysqld_safe
sed -i "s/trio/$USER/" ../my.cnf
./mysqld --defaults-file=$HOME/app/mysql/my.cnf --initialize-insecure --basedir=$HOME/app/mysql --datadir=$HOME/app/mysql/data 
./mysql.server start


#mysql --defaults-file=$HOME/app/mysql/my.cnf -u root -p
# delete from mysql.user where user='' or host!='localhost';
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'triotest';
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY 'triotest';
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.%' IDENTIFIED BY 'triotest';
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'ip' IDENTIFIED BY 'triotest';
# flush privileges;
