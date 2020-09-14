#!/bin/bash
echo "==============================================="
echo "# Backup Wordpress - MySQL config & data      #"
echo "# Backup tar files for all data volume        #"
echo "# Usage:                                      #"
echo "# ./backup.sh -o <output_directory>           #"
echo "# All tar files will be created in output dir #"
echo "==============================================="

RUNNING_DIR=$PWD
volumes=(wp_data db_data db_config)

while getopts v:o: flag
do
    case "${flag}" in
        o) output=${OPTARG};;
    esac
done

is_docker_installed() {
    docker ps > /dev/null 2>&1
}
is_volume_exists() {
    docker volume inspect $1 > /dev/null 2>&1
}


is_docker_installed
if [[ $? -ne 0 ]]; then
    echo "Can not run docker command"
    echo "Skipped backup process..."
    exit 0
fi

for volume in "${volumes[@]}"; do 
    is_volume_exists $volume
    if [[ $? -ne 0 ]]; then
        echo "${volume} volume is not exists"
        echo "Skipped backup process..."
        exit 0
    fi
    CID=$(docker run -d -v ${volume}:/${volume} busybox true)
    if [[ $output == "" ]]; then
        output="./"
    fi
    mkdir -p $output
    cd /tmp
    rm -f ${volume}.tar
    docker cp $CID:/${volume} ./
    cd $volume
    tar cvf ../${volume}.tar ./ > /dev/null 2>&1
    echo "Archived volume $volume"
    rm -rf ${volume}

    cd $RUNNING_DIR > /dev/null 2>&1
    cp /tmp/${volume}.tar $output
    docker rm $CID > /dev/null 2>&1
done