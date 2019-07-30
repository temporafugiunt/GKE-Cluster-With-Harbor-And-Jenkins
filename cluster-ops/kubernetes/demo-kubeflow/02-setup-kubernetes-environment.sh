#!/bin/bash
# 
#   Sets up the environment and secrets necessary for the devops-sandbox-cluster Kubernetes instance in Azure.
#    
#   Authors: James Eby
#

export ORIG_DIR=$(pwd)

export CLUSTER_FILES_PATH=$ORIG_DIR
export COMMON_FILES_PATH="$(dirname "$ORIG_DIR")"/common
export COMMON_BASH_FILES_PATH=$COMMON_FILES_PATH/bash-files

# Connect to proper cluster in this command window.
. ./init-kube-connection.sh

# # Set necessary secrets as environment variables.
# #. ../../azure/devops-sandbox-cluster/.secrets/set-sql-server-environment-variables.sh
. $COMMON_FILES_PATH/.secrets/set-external-resources-environment-variables.sh

# Create service account and RBAC for tiller.
kubectl create sa tiller -n kube-system
kubectl create clusterrolebinding tiller-cr-binding --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# SECRETS

# #NOTE: NEVER EVER PUT A $ IN A PASSWORD FOR THESE USERS, it won't work -p parameter which also affects Jenkins.
# if [ "$REGISTRY_URL" == 'hub.docker.com' ]
# then
#     # Create the private docker registry connection secret.
#     kubectl create secret docker-registry registry-regcred --docker-server=https://index.docker.io/v1/ --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
#     kubectl create secret docker-registry registry-regcred -n build --docker-server=https://index.docker.io/v1/ --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
#     kubectl create secret docker-registry registry-regcred -n production --docker-server=https://index.docker.io/v1/ --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
#     kubectl create secret docker-registry registry-regcred -n beta --docker-server=https://index.docker.io/v1/ --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
# else
#     # Create the private docker registry connection secret.
#     kubectl create secret docker-registry registry-regcred --docker-server=https://${REGISTRY_URL} --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
#     kubectl create secret docker-registry registry-regcred -n build --docker-server=https://${REGISTRY_URL} --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
#     kubectl create secret docker-registry registry-regcred -n production --docker-server=https://${REGISTRY_URL} --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
#     kubectl create secret docker-registry registry-regcred -n beta --docker-server=https://${REGISTRY_URL} --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_USER_PASSWORD --docker-email=$REGISTRY_EMAIL
# fi

# # Give jenkins service account right to pull images from private repository.
# kubectl patch serviceaccount -n build jenkins-builder -p '{"imagePullSecrets": [{"name": "registry-regcred"}]}'

kubectl apply -f $COMMON_FILES_PATH/PersistentVolume/iscsi01-pv.yaml