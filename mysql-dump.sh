#!/bin/bash

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

if [ -z "$DB_USER" ]; then
    echo "Missing User default is : root"
    DB_USER="root"
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "Missing Password default is : ''"
    DB_PASSWORD=""
fi

if [ -z "$DB_HOST" ]; then
    echo "Missing HOST default is : 127.0.0.1"
    DB_HOST="127.0.0.1"
fi

if [ -z "$DB_PORT" ]; then
    echo "Missing Port default is : 3306"
    DB_PORT="3306"
fi

if [ -z "$DB_NAME"]; then
    echo "Missing Database Name default is : all database"
    DB_NAME="all-database"
fi

if [ "$DUMP_ALL_DB" = true ]; then
    echo "Dump ALL database"
fi

if [ -z "$OBS_BUCKET" ] || [ -z "$BACKUP_PATH" ] || [-z "$BACKUP_DIR"]; then
    echo "Please ensure all required environment variables (OBS_BUCKET, BACKUP_PATH, BACKUP_DIR) are set."
    exit 1
fi

BACKUP_FILENAME="${DB_NAME}_backup_$(date +'%d-%m-%Y_%H-%M-%S').sql.gz"
BACKUP_PATH="$BACKUP_PATH/$BACKUP_FILENAME"
OBS_OBJECT_KEY="$BACKUP_DIR/$BACKUP_FILENAME"

dump_database() {
    echo "Creating file dump..."
    
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
    rm -rf "*.sql.gz"
    
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
