#!/bin/sh
# mysql数据库备份 可以指定备份保留次数，指定不备份数据库

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

db_host="localhost"
db_user="tmper"
db_passwd="MT1IdhVds"
#保留备份数
savebakcount=8
#排除备份数据库
notbakdatabase=('performance_schema','information_schema','mysql','test','sys')
# 备份文件目录
backup_dir="/home/mysql_bak"
# 备份文件时间格式(yyyy-mm-dd_HH_MM)
time="$(date +"%Y-%m-%d_%H_%M")"

# 要备份的mysql信息
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
MKDIR="mkdir"
RM="rm"
MV="mv"
GZIP="gzip"
# 检查目录是否可写
test ! -w $backup_dir && echo "Error: $backup_dir is un-writeable." && exit 0
# 测试是否创建了临时备份目录
test ! -d "$backup_dir/backup.0/" && $MKDIR "$backup_dir/backup.0/"
# 得到所有的数据库信息
all_db="$($MYSQL -u $db_user -h $db_host -p$db_passwd -Bse 'show databases')"
for db in $all_db;do
#数据库是否为排除备份数据库
echo "${notbakdatabase[@]}" | grep -wq "$db" &&  continue
echo "正在备份${db}..."
$MYSQLDUMP   --single-transaction -u $db_user -h $db_host -p$db_passwd $db | $GZIP -9 > "$backup_dir/backup.0/$time.$db.sql.gz"
done

# delete the oldest backup
test -d "$backup_dir/backup.$savebakcount/" && $RM -rf "$backup_dir/backup.$savebakcount"
# rotate backup directory
for int in  `seq $savebakcount -1 0`
do
if(test -d "$backup_dir"/backup."$int");then
next_int=`expr $int + 1`
$MV "$backup_dir"/backup."$int" "$backup_dir"/backup."$next_int"
fi
done

[[ -d "$backup_dir"/backup.1 ]] || echo "back error"

exit 0;


#备份数据库定时计划
#23 23 * * * (flock -xn /tmp/mysqlbak.lock -c /opt/mysqlbak.sh >>/var/log/mysql_bak.log 2>&1)
#grant select, RELOAD, SHOW DATABASES, LOCK TABLES on *.* to 'tmper'@localhost identified by 'MT1IdhVds'
