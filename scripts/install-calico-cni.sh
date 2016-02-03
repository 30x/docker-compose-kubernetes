#!/bin/bash

# Create necessary directories.
docker-machine ssh $DOCKER_MACHINE_NAME sudo mkdir -p /etc/cni/net.d
docker-machine ssh $DOCKER_MACHINE_NAME sudo mkdir -p /opt/cni/bin
docker-machine ssh $DOCKER_MACHINE_NAME sudo mkdir -p /opt/bin
docker-machine ssh $DOCKER_MACHINE_NAME sudo mkdir -p /var/run/calico
docker-machine ssh $DOCKER_MACHINE_NAME sudo mkdir -p /var/log/calico

# Ensure the network config file exists.
docker-machine scp 10-calico.conf $DOCKER_MACHINE_NAME:/home/docker
docker-machine ssh $DOCKER_MACHINE_NAME sudo mv /home/docker/10-calico.conf /etc/cni/net.d/

# Download the CNI plugin.
docker-machine ssh $DOCKER_MACHINE_NAME sudo wget -O /opt/cni/bin/calico https://github.com/projectcalico/calico-cni/releases/download/v1.0.0/calico
docker-machine ssh $DOCKER_MACHINE_NAME sudo chmod +x /opt/cni/bin/calico

# Ensure proper kernel modules installed.
docker-machine ssh $DOCKER_MACHINE_NAME sudo modprobe -a xt_set ip6_tables
