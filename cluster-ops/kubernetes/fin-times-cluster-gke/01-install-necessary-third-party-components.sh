#!/bin/bash

# 
#   This file installs the extra components necessary for an example pipeline project.
#    
#   The setup of this project follows the documentation of the eample found at
#   https://www.kubeflow.org/docs/gke/gcp-e2e/
#   refer there for a fuller description of what the code is doing.
#
#   Authors: James Eby
#
export ORIG_DIR=$(pwd)

export CLUSTER_FILES_PATH=$ORIG_DIR
export COMMON_FILES_PATH="$(dirname "$ORIG_DIR")"/common
export COMMON_BASH_FILES_PATH=$COMMON_FILES_PATH/bash-files

. $CLUSTER_FILES_PATH/01a-Cluster-Connect.sh

# Create service account and RBAC for tiller.
kubectl create sa tiller -n kube-system
kubectl create clusterrolebinding tiller-cr-binding --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# Establishes connection to kubernetes cluster.
. $COMMON_BASH_FILES_PATH/install-helm-locally.sh

# Initialize tiller in the new cluster (Tiller goes away with V3 of helm),
helm init --service-account tiller

echo 'Sleeping for 30 seconds after installing Tiller'
sleep 30s

# Install Seldon Core using istio as its gateway.
helm install seldon-core-operator --name seldon-core --repo https://storage.googleapis.com/seldon-charts --set usageMetrics.enabled=true --set istio.enabled=true --set istio.gateway=istio-ingressgateway --namespace seldon-system 

# Install the NFS File Provisioner
export NFS_NAME=auto-provisioned-pvcs

gcloud beta filestore instances create ${NFS_NAME}     --project=${PROJECT}     --zone=${ZONE}     --tier=STANDARD     --file-share=name="volumes",capacity=1TB     --network=name="default",reserved-ip-range="10.0.0.0/29"

export FSADDR=$(gcloud beta filestore instances describe ${NFS_NAME} --project=${PROJECT} --zone=${ZONE} --format="value(networks.ipAddresses[0])")

echo "${FSADDR} is the NFS address."

helm install stable/nfs-client-provisioner --name nfs-cp --set nfs.server=${FSADDR} --set nfs.path=/volumes
# kubectl rollout status  deploy/nfs-cp-nfs-client-provisioner -n kubeflow