#!/bin/bash

set -e

require_command_exists() {
    command -v "$1" >/dev/null 2>&1 || { echo "$1 is required but is not installed. Aborting." >&2; exit 1; }
}

require_command_exists kubectl
require_command_exists docker
require_command_exists docker-compose

this_dir=$(cd -P "$(dirname "$0")" && pwd)

docker info > /dev/null
if [ $? != 0 ]; then
    echo "A running Docker engine is required. Is your Docker host up?"
    exit 1
fi

# Ensure Calico CNI plugin is installed.  If running locally, just 
# run the install script.  Otherwise, we need to scp it to the 
# docker machine and run it there.
if [[ -z "$DOCKER_MACHINE_NAME" ]]; then
	# Running locally - just run the script.
  	cd "$this_dir/scripts"
  	./install-calico-cni.sh
else
	# Copy script to docker-machine and run.
	docker-machine scp $this_dir/scripts/install-calico-cni.sh $DOCKER_MACHINE_NAME:/home
	docker-machine ssh /home/install-calico-cni.sh
fi

cd "$this_dir/kubernetes"
docker-compose up -d

cd "$this_dir/calico"
docker-compose up -d

cd "$this_dir/scripts"

source port-config.sh
source docker-machine-port-forwarding.sh
forward_port_if_not_forwarded $KUBERNETES_API_PORT
forward_port_if_not_forwarded $REGISTRY_PORT

./wait-for-kubernetes.sh
./create-kube-system-namespace.sh
./activate-dns.sh
./activate-kube-ui.sh
