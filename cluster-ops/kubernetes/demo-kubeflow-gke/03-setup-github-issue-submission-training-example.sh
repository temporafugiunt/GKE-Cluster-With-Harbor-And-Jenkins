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

# conda create --name kubeflow-github
# . activate kubeflow-github
# conda deactivate

# Add a node with GPU support
gcloud container node-pools create accel \
    --project $PROJECT \
    --zone $ZONE \
    --cluster $KFAPP_NAME \
    --accelerator type=nvidia-tesla-k80,count=4 \
    --num-nodes 1 \
    --machine-type n1-highmem-8 \
    --disk-size=220GB \
    --scopes cloud-platform \
    --verbosity error

# Add a daemonset that will detect nodes with nvidia hardware and install nvidia drivers for them.
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/stable/nvidia-driver-installer/cos/daemonset-preloaded.yaml

# Port forwarding reverse proxy to ambassador 
# kubectl port-forward -n kubeflow svc/ambassador 8080:80

#curl -O https://raw.githubusercontent.com/amygdala/co-snippets/master/ml/kubeflow-pipelines/samples/kubeflow-tf/gh_sum.py

conda install pyyaml -y

. $COMMON_BASH_FILES_PATH/install-ksonnet-locally.sh
