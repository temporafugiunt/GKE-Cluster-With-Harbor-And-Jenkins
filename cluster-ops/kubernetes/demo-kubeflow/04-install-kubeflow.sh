#!/bin/bash

# 
#   Installs Istio, cert-manager, Harbor, and Jenkins into the kubernetes cluster.
#    
#   Authors: James Eby
#

export ORIG_DIR=$(pwd)

. $ORIG_DIR/init-kube-connection.sh

export CLUSTER_FILES_PATH=$ORIG_DIR
export COMMON_FILES_PATH="$(dirname "$ORIG_DIR")"/common
export COMMON_BASH_FILES_PATH=$COMMON_FILES_PATH/bash-files
export KF_VERSION=v0.6.1
export KF_DOWNLOAD=https://github.com/kubeflow/kubeflow/releases/download/$KF_VERSION/kfctl_"$KF_VERSION"_darwin.tar.gz

echo "Downloading from $KF_DOWNLOAD"
curl -L $KF_DOWNLOAD > $CLUSTER_FILES_PATH/kfctl_"$KF_VERSION"_darwin.tar.gz
tar -xvf $CLUSTER_FILES_PATH/kfctl_"$KF_VERSION"_darwin.tar.gz

# Add kfctl to PATH, to make the kfctl binary easier to use.
export PATH=$PATH:$(pwd)
export KFAPP="kubeflow-demo"
export CONFIG="https://raw.githubusercontent.com/kubeflow/kubeflow/master/bootstrap/config/kfctl_existing_arrikto.0.6.yaml"

# Specify credentials for the default user.
export KUBEFLOW_USER_EMAIL="admin@kubeflow.org"
export KUBEFLOW_PASSWORD="12341234"

kfctl init ${KFAPP} --config=${CONFIG} -V
cd ${KFAPP}
kfctl generate all -V
kfctl apply all -V

cd $CLUSTER_FILES_PATH

export LOAD_BALANCER_EXTERNAL_IP=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Your external Load Balancer IP Address is $LOAD_BALANCER_EXTERNAL_IP, please update your DNS records if needed."


