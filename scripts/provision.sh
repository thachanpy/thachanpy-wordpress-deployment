#!/bin/bash
echo "=========================================="
echo "# Start wordpress - mysql container      #"
echo "=========================================="

WORK_DIR=`dirname $(readlink -f $0)`

declare -a volumes
volumes=(wp_data db_data db_config)

is_docker_installed() {
    sudo docker ps > /dev/null 2>&1
}

is_docker_compose_installed() {
    sudo docker-compose version > /dev/null 2>&1
}

is_volume_exists() {
    sudo docker volume inspect $1 > /dev/null 2>&1
}

is_docker_installed
if [[ $? -ne 0 ]]; then
    echo "Can not run docker command"
    echo "Skipped deploy process..."
    exit 0
fi
is_docker_compose_installed
if [[ $? -ne 0 ]]; then
    echo "Can not run docker-compose command"
    echo "Skipped deploy process..."
    exit 0
fi

for volume in "${volumes[@]}"; do 
    is_volume_exists $volume
    if [[ $? -ne 0 ]]; then
        sudo docker volume create --name=$volume > /dev/null 2>&1
        echo "Created $volume volume"
    fi
done
cd $WORK_DIR/..
sudo docker-compose up -d
cd - > /dev/null 2>&1