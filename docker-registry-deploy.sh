#!/bin/sh
set -o errexit

# create registry container unless it already exists
reg_name='docker-private-registry_docker-registry_1'
reg_port='5001'
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker-compose up --build -d
fi
# connect the registry to the cluster network
# (the network may already be connected)
docker network connect "kind" "${reg_name}" || true

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
kubectl apply -f registry-configmap.yaml
