#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${YELLOW}.env ${RED}file not found!"
    exit 1
fi

if [ -z "$DB_USER" ]; then
    echo -e "${YELLOW}Missing User default is : ${GREEN}root"
    DB_USER="root"
fi

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${YELLOW}Missing Password default is : ${GREEN}''"
    DB_PASSWORD=""
fi

if [ -z "$DB_HOST" ]; then
    echo -e "${YELLOW}Missing HOST default is : ${GREEN}127.0.0.1"
    DB_HOST="127.0.0.1"
fi

if [ -z "$DB_PORT" ]; then
    echo -e "${YELLOW}Missing Port default is : ${GREEN}3306"
    DB_PORT="3306"
fi

if [ -z "$DB_NAME" ]; then
    echo -e "${YELLOW}Missing Database Name default is : ${GREEN}all database"
    DB_NAME="all-database"
fi

if [ "$DUMP_ALL_DB" = true ]; then
    echo -e "${YELLOW}Dump ALL database"
    DB_NAME="all-database"
fi

if [ -z "$OBS_BUCKET" ] || [ -z "$BACKUP_PATH" ] || [ -z "$BACKUP_DIR" ]; then
    echo -e "${RED}Please ensure all required environment variables (${YELLOW}OBS_BUCKET${RED}, ${YELLOW}BACKUP_PATH${RED}, ${YELLOW}BACKUP_DIR${RED}) are set"
    exit 1
fi

BACKUP_FILENAME="${DB_NAME}_backup_$(date +'%d-%m-%Y_%H-%M-%S').sql.gz"
BACKUP_PATH="$BACKUP_PATH/$BACKUP_FILENAME"
OBS_OBJECT_KEY="$BACKUP_DIR/$BACKUP_FILENAME"

dump_database() {
    echo -e "${GREEN}Creating file dump..."
    
    if [ "$DB_NAME" = "null" ] || [ "$DUMP_ALL_DB" = "true" ] || [ -z "$DB_NAME" ]; then
        mysqldump -u"$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" \
            -P "$DB_PORT" --single-transaction --quick --compress --routines --triggers --events --hex-blob --all-databases \
            | gzip > "$BACKUP_PATH"
    else
        mysqldump -u"$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" \
            -P "$DB_PORT" "$DB_NAME" --single-transaction --quick --compress --routines --triggers --events --hex-blob \
            | gzip > "$BACKUP_PATH"
    fi

    if [ $? -ne 0 ]; then
        echo -e "${RED}Dump File Fail!"
        return 1
    else
        echo -e "${GREEN}Create file dump success: ${BLUE}$BACKUP_PATH"
        return 0
    fi
}


upload_to_obs() {
    echo -e "${GREEN}Uploading file to ${BLUE}OBS..."
    obsutil cp "$BACKUP_PATH" "obs://$OBS_BUCKET/$OBS_OBJECT_KEY"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Upload file to OBS Fail!"
        return 1
    else
        echo -e "${GREEN}Success upload file to OBS: ${BLUE}$OBS_OBJECT_KEY"
        return 0
    fi
}

remove_backup_file() {
    echo -e "${YELLOW}Removing local backup file..."
    rm -rf "*.sql.gz"
    
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}Remove backup success: ${GREEN}$BACKUP_PATH"
    else
        echo -e "${RED}Fail remove backup file!"
    fi
}

if dump_database; then
    if upload_to_obs; then
        remove_backup_file
    fi
fi
