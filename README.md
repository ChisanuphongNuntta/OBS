# Install OBS Client
**Work For dabian 12**
create file .sh
```
#!/bin/bash

ACCESS_KEY=Your-access-key
PRIVATE_KEY=Your-private-key
echo 

wget https://obs-community-intl.obs.ap-southeast-1.myhuaweicloud.com/obsutil/current/obsutil_linux_amd64.tar.gz

tar -xzvf obsutil_linux_amd64.tar.gz
cd obsutil_linux_amd64_*/
chmod +x obsutil

mv obsutil /usr/local/bin/obsutil

obsutil config -i $ACCESS_KEY -k $PRIVATE_KEY -e obs.ap-southeast-2.myhuaweicloud.com

cd ..
rm -rf obsutil_linux_amd64_*/
rm obsutil_linux_amd64.tar.gz
```

## Don't forget change *ACCESS_KEY* and *PRIVATE_KEY*
Then success edit save and run *bash*

### Your config file location `~/.obsutilconfig`
If want to change `ACCESS_KEY`(AK) and `PRIVATE_KEY`(SK)

# DUMP SQL SCRIPT(Python)
### Install `Python3.10` up and `python3-pip`

# DUMP SQL SCRIPT(Bash)
### Follow bash script `mysql-dump.sh`

create `ENV` file (same location python script)
```
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=127.0.0.1
DB_NAME=your_database_name

OBS_BUCKET=your_obs_bucket
BACKUP_PATH=/path/to/backup
```

after set env run python or bash script DONE!

# !HELP Paramiter
```
--single-transaction:

ใช้สำหรับ InnoDB tables เพื่อลดการล็อก table โดย dump ข้อมูลในลักษณะของ single transaction
ควรใช้คู่กับ --quick เพื่อช่วยลดการใช้หน่วยความจำระหว่างการ dump ข้อมูลขนาดใหญ่
--quick:

อ่านข้อมูลจากฐานข้อมูลเป็นบรรทัดๆ ซึ่งช่วยลดการใช้หน่วยความจำในเครื่อง client เมื่อทำการ dump ข้อมูลขนาดใหญ่
--routines:

ทำการ backup stored procedures และ functions เพื่อให้สามารถ restore โครงสร้างที่เกี่ยวข้องกับ logic ของฐานข้อมูลได้ครบถ้วน
--triggers:

รวม trigger ทั้งหมดใน dump file เพื่อให้ trigger ถูก restore กลับมาด้วย
--events:

รวม events ในฐานข้อมูล ซึ่งมีประโยชน์หากใช้งาน MySQL event scheduler
--add-drop-database:

เพิ่มคำสั่ง DROP DATABASE IF EXISTS ก่อน CREATE DATABASE เพื่อให้แน่ใจว่าการ restore ไม่ทำให้เกิดปัญหาจาก database ซ้ำ
--add-drop-table:

เพิ่มคำสั่ง DROP TABLE IF EXISTS ก่อน CREATE TABLE ในการสร้าง table ใหม่ ช่วยลดความเสี่ยงจากการ restore ซ้ำ
--compress:

บีบอัดการส่งข้อมูลระหว่าง client และ server ช่วยลดการใช้แบนด์วิดท์ (ใช้ได้ถ้าเชื่อมต่อผ่าน network)

--hex-blob:

ใช้สำหรับการ dump ข้อมูลแบบ binary (BLOB) ให้มีความเสถียรมากขึ้นเพื่อป้องกันข้อมูลเสียหาย

--set-gtid-purged=OFF !!(OPTIONAL)

ใช้ในกรณีที่ active - standby ด้วย GTID
```

# Cron Tap
`$crontab -e` 
```
* * * * * command to be executed
- - - - -
| | | | |
| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
| | | ------- Month (1 - 12)
| | --------- Day of month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
```
