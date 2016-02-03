#!/bin/bash

# Create necessary directories.
docker-machine ssh dev sudo mkdir -p /etc/cni/net.d
docker-machine ssh dev sudo mkdir -p /opt/cni/bin
docker-machine ssh dev sudo mkdir -p /opt/bin
docker-machine ssh dev sudo mkdir -p /var/run/calico
docker-machine ssh dev sudo mkdir -p /var/log/calico

# Ensure the network config file exists.
docker-machine scp 10-calico.conf dev:/home/docker
docker-machine ssh dev sudo mv /home/docker/10-calico.conf /etc/cni/net.d/

# Download the CNI plugin.
docker-machine ssh dev sudo wget -O /opt/cni/bin/calico https://github.com/projectcalico/calico-cni/releases/download/v1.0.0/calico
docker-machine ssh dev sudo chmod +x /opt/cni/bin/calico

# Ensure proper kernel modules installed. 
docker-machine ssh dev sudo modprobe -a xt_set ip6_tables
