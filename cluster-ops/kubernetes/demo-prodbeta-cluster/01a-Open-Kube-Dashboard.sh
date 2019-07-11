#!/bin/bash

# 
#   Opens the kubectl dashboard.
#    
#   Authors: James Eby
#

export ORIG_DIR=$(pwd)

export CLUSTER_FILES_PATH=$ORIG_DIR
export COMMON_FILES_PATH="$(dirname "$ORIG_DIR")"/common
export COMMON_BASH_FILES_PATH=$COMMON_FILES_PATH/bash-files

# Make sure we are where we need to be to setup the kubeconfig properly
cd $CLUSTER_FILES_PATH

# Connect to proper cluster in this command window.
. $CLUSTER_FILES_PATH/../../azure/demo-production-cluster/init-kube-connection.sh

echo 'proxy opened at:'
echo 'http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=default'

kubectl proxy

