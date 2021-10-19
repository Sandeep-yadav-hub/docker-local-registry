## Docker Local Registry with kind cluster

- Create a file name docker-registry-deploy.sh 
```
#!/bin/sh
set -o errexit

# create registry container unless it already exists
reg_name='kind-registry'
reg_port='5000'
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:5000"]
EOF

# connect the registry to the cluster network
# (the network may already be connected)
docker network connect "kind" "${reg_name}" || true

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF


``` 

- Give execute permission to docker-registry-deploy.sh.

- Execute docker-registry-deploy.sh.

OR

- Clone this repository 
```
git clone https://github.com/Sandeep-yadav-hub/docker-local-registry.git
```
- Give execute permission to docker-registry-deploy.sh.

- Execute docker-registry-deploy.sh.

- Change/create a kind cluster 

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: app-clusters
# add this into your kind-config file from here
containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:<PORT>"]
      endpoint = ["http://kind-registry:5000"]
# till here
```
- PORT is same as registry_port in docker-registry-deploy.sh.




