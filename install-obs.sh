#!/bin/bash

ACCESS_KEY=Your-access-key
PRIVATE_KEY=Your-private-key
echo 

wget https://obs-community-intl.obs.ap-southeast-1.myhuaweicloud.com/obsutil/current/obsutil_linux_amd64.tar.gz

tar -xzvf obsutil_linux_amd64.tar.gz
cd obsutil_linux_amd64_*/
chmod +x obsutil

sudo mv obsutil /usr/local/bin/obsutil

obsutil config -i $ACCESS_KEY -k $PRIVATE_KEY -e obs.ap-southeast-2.myhuaweicloud.com

cd ..
rm -rf obsutil_linux_amd64_*/
rm obsutil_linux_amd64.tar.gz