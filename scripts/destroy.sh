#!/bin/bash
echo "======================================="
echo "# Destroy wordpress - mysql container #"
echo "======================================="
 
while true; do
    read -p "Do you want to destroy all wordpress container? (y/N) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        *) exit;;
    esac
done

WORK_DIR=`dirname $(readlink -f $0)`

declare -a volumes
volumes=(wp_data db_data db_config)

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
    echo "Skipped destroy process..."
    exit 0
fi
is_docker_compose_installed
if [[ $? -ne 0 ]]; then
    echo "Can not run docker-compose command"
    echo "Skipped destroy process..."
    exit 0
fi

cd $WORK_DIR/..
docker-compose down
cd $RUNNING_DIR

for volume in "${volumes[@]}"; do 
    is_volume_exists $volume
    if [[ $? -eq 0 ]]; then
        docker volume rm $volume > /dev/null 2>&1
        echo "Removed $volume volume"
    fi
done