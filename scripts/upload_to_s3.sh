#!/bin/bash

check_aws=`command -v aws`
if [[ check_aws == 1 ]]; then
    apt install awscli -y
fi

backup_folder=$1
if [[ $backup_folder == "" ]]; then
    echo "Need to add folder parameter"
    exit 1
fi

/data/thachanpy/thachanpy-wordpress-deployment/scripts/backup.sh -o $backup_folder

for entry in "$backup_folder"/*
do 
    if [[ $entry == *.tar ]]; then
        aws s3 cp $entry s3://thachanpy/backup/
    fi
done