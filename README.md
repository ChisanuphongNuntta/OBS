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

# DUMP SQL SCRIPT
### Install `Python3.10` up and `python3-pip`

create `ENV` file (same location python script)
```
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=127.0.0.1
DB_NAME=your_database_name

OBS_BUCKET=your_obs_bucket
BACKUP_PATH=/path/to/backup
```

after set env run python script DONE!

# Cron Tap