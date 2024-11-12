#!/bin/bash

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$OBS_BUCKET" ] || [ -z "$BACKUP_PATH" ]; then
    echo "Please ensure all required environment variables (DB_USER, DB_PASSWORD, DB_HOST, DB_NAME, OBS_BUCKET, BACKUP_PATH) are set."
    exit 1
fi

BACKUP_FILENAME="${DB_NAME}_backup_$(date +'%Y%m%d_%H%M%S').sql"
BACKUP_PATH="$BACKUP_PATH/$BACKUP_FILENAME"
OBS_OBJECT_KEY="$BACKUP_FILENAME"

dump_database() {
    echo "Creating file dump..."
    mysqldump -u"$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" \
        -P "$DB_PORT" "$DB_NAME" --single-transaction --quick --compress --routines --triggers --events --hex-blob --all-databases \
        | gzip \
        > "$BACKUP_PATH"
    
    if [ $? -ne 0 ]; then
        echo "Dump File Fail!"
        return 1
    else
        echo "Create file dump success: $BACKUP_PATH"
        return 0
    fi
}

upload_to_obs() {
    echo "Uploading file to OBS..."
    obsutil cp "$BACKUP_PATH" "obs://$OBS_BUCKET/$OBS_OBJECT_KEY"
    
    if [ $? -ne 0 ]; then
        echo "Upload file to OBS Fail!"
        return 1
    else
        echo "Success upload file to OBS: $OBS_OBJECT_KEY"
        return 0
    fi
}

remove_backup_file() {
    echo "Removing local backup file..."
    rm "$BACKUP_PATH"
    
    if [ $? -eq 0 ]; then
        echo "Remove backup success: $BACKUP_PATH"
    else
        echo "Fail remove backup file!"
    fi
}

if dump_database; then
    if upload_to_obs; then
        remove_backup_file
    fi
fi
