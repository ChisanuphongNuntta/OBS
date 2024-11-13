#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

if [ -z "$ACCESS_KEY" ] || [ -z "$PRIVATE_KEY" ]; then
    echo "${RED}Please ensure all required environment variables (ACCESS_KEY, PRIVATE_KEY) are set"
    exit 1
fi

wget https://obs-community-intl.obs.ap-southeast-1.myhuaweicloud.com/obsutil/current/obsutil_linux_amd64.tar.gz

tar -xzvf obsutil_linux_amd64.tar.gz
cd obsutil_linux_amd64_*/
chmod +x obsutil

mv obsutil /usr/local/bin/obsutil

obsutil config -i $ACCESS_KEY -k $PRIVATE_KEY -e obs.ap-southeast-2.myhuaweicloud.com

cd ..
rm -rf obsutil_linux_amd64_*/
rm obsutil_linux_amd64.tar.gz