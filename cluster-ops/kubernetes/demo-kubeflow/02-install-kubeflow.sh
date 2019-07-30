#!/bin/bash

# 
#   Installs Istio, cert-manager, Harbor, and Jenkins into the kubernetes cluster.
#    
#   Authors: James Eby
#

export ORIG_DIR=$(pwd)

export CLUSTER_FILES_PATH=$ORIG_DIR
export COMMON_FILES_PATH="$(dirname "$ORIG_DIR")"/common
export COMMON_BASH_FILES_PATH=$COMMON_FILES_PATH/bash-files
export KF_VERSION=v0.6.1
export KF_DOWNLOAD=https://github.com/kubeflow/kubeflow/releases/download/$KF_VERSION/kfctl_"$KF_VERSION"_linux.tar.gz

echo "Downloading from $KF_DOWNLOAD"
curl -L $KF_DOWNLOAD > $CLUSTER_FILES_PATH/kfctl_"$KF_VERSION"_linux.tar.gz
tar -xvf $CLUSTER_FILES_PATH/kfctl_"$KF_VERSION"_linux.tar.gz