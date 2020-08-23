#!/bin/bash

MYSQLLOG='/var/log/mysqld.log'
USER_SQL_CONF='/root/.my.cnf'
SQL_HOST='127.0.0.1'
SQL_USER='root'
TMP_PASSW=`cat $MYSQLLOG | grep "A temporary password is generated" | sed 's|.* ||' | tail -n 1`
FIN_PASSW='PrivetMedved'

echo -e "[Client]
host=$SQL_HOST
user=$SQL_USER
password=$TMP_PASSW" > $USER_SQL_CONF

mkdir /var/lib/mysql/data /var/lib/mysql/tmpdir

mysql --connect-expired-password -e "SET GLOBAL validate_password_policy=LOW;"
mysql --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Temp$TMP_PASSW';"
sed "s|$TMP_PASSW|Temp$TMP_PASSW|" -i $USER_SQL_CONF
mysql --connect-expired-password -e "uninstall plugin validate_password;"
mysql --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$FIN_PASSW';"
sed "s|Temp$TMP_PASSW|$FIN_PASSW|" -i $USER_SQL_CONF
