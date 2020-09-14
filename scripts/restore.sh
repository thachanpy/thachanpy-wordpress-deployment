#!/bin/bash
echo "============================================================"
echo "# Restore wordpress - mysql volume                         #"
echo "# All tar backup files should be located on same directory #"
echo "# Should deploy container first                            #"
echo "# Usage:                                                   #"
echo "# ./restore.sh -i <input_directory>                        #"
echo "============================================================"

WORK_DIR=`dirname $(readlink -f $0)`
RUNNING_DIR=$PWD
declare -a volumes
volumes=(wp_data db_data db_config)

while getopts i: flag
do
    case "${flag}" in
        i) input=${OPTARG};;
    esac
done

is_docker_installed() {
    docker ps > /dev/null 2>&1
}

is_docker_compose_installed() {
    docker-compose version > /dev/null 2>&1
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
if [[ ! -d ${input} ]]; then
    echo "Input directory does not exists - Skipped..."
    exit 0
fi
     
cd $input
for volume in "${volumes[@]}"; do 
    is_volume_exists $volume
    if [[ $? -ne 0 ]]; then
        echo "${volume} volume is not exists"
        echo "Skipped restore process..."
        exit 0
    fi
    
    if [[ -f ${volume}.tar ]]; then
        mkdir $volume > /dev/null 2>&1
        tar xvf ${volume}.tar -C ./${volume} > /dev/null 2>&1
        CID=$(docker run -d -v ${volume}:/${volume} busybox true)
        docker cp ./${volume} ${CID}:/
        rm -rf ./${volume}
        docker rm $CID > /dev/null 2>&1
        echo "Restored ${volume}"
    else
        echo "${volume}.tar does not exists - Skipped..."
    fi
done
cd $WORK_DIR/..
docker-compose down
docker-compose up -d
cd $RUNNING_DIR
