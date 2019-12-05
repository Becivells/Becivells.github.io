#!/bin/sh
# mysql数据库恢复脚本可以指定恢复的次数

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

db_host="localhost"
db_user="root"
db_passwd="123#456"
backup_dir="/home/mysql_bak"
# 要备份的mysql信息
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"

GUNZIP="gunzip"
# 检查目录是否可写

BACK_PATH=$1

test ! -d "$BACK_PATH" && echo "Error: please input back_path or $backup_PATH is not find." && exit 0

cd "$BACK_PATH"

for db in `ls|grep sql.gz`;do
	dbname=`echo $db|cut -d . -f 2`
	#create databases
	echo "Will import $dbname DATA from $BACK_PATH/$db...."
done


echo -n "will recover data Please enter yes or no  -> "
read judge

if [[ "$judge" != "yes" ]]; then
	echo "not input yes exit!!!"
	exit 0;
fi

for db in `ls|grep sql.gz`;do
	dbname=`echo $db|cut -d . -f 2`
	#create databases
	create_db="CREATE DATABASE IF NOT EXISTS $dbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
	echo $create_db
	echo "CREATE TABLE $dbname"
	echo ''
	$MYSQL -u $db_user -h $db_host -p$db_passwd -e "$create_db"
	echo "IMPORT $db DATA from BACK...."
	$GUNZIP -c $db |$MYSQL -u $db_user -h $db_host -p$db_passwd $dbname
done
exit 0;


#备份数据库定时计划
#23 23 * * * (flock -xn /tmp/mysqlbak.lock -c /opt/mysqlbak.sh >>/var/log/mysql_bak.log 2>&1)
#grant select, RELOAD, SHOW DATABASES, LOCK TABLES on *.* to 'tmper'@localhost identified by 'MT1IdhVds'
