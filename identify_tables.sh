#!/bin/bash
password=root
username=root

dump_folder=data_dump
org_id=1102
rm -rf $dump_folder/data
mkdir -p $dump_folder/data
mysql -N -p$password -u $username -e "show databases" > db_name.txt

for db_name in `cat db_name.txt`; do
	printf "starting db $db_name\n**************************************************\n"
	mkdir -p $dump_folder/data/$db_name
    mysql -N -p$password -u $username -e "select table_name from information_schema.columns where column_name in ('org_id', 'publisher_id') and TABLE_SCHEMA not in ('Temp', 'tempdb', 'data_cleanup', 'performance_logs') and TABLE_SCHEMA = '$db_name'" > tables.txt;
	for tbl_name in `cat tables.txt`; do
		echo "use $db_name;" > $dump_folder/data/"$db_name/$tbl_name"_dump.sql
    	mysqldump -p$password -u $username $db_name $tbl_name --no-create-info --complete-insert --compact --skip-comments --skip-tz-utc --skip-lock-tables --where "org_id=$org_id"  >> $dump_folder/data/"$db_name/$tbl_name"_dump.sql
		echo "done exporting $tbl_name"
	done;
done;

db_name=user_management
tbl_name=loyalty
mysqldump -p$password -u $username $db_name $tbl_name --no-create-info --complete-insert --compact --skip-comments --skip-tz-utc --skip-lock-tables --where "publisher_id=$org_id"  >> $dump_folder/data/"$db_name/$tbl_name"_dump.sql

zip -r `hostname`_dump.zip $dump_folder

