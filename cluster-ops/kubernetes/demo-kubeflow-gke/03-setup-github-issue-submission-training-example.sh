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

# EXPLICIT GPU SETUP SUPPORT
# --------------------------
# # Explicitly adding a node with GPU support
# gcloud container node-pools create accel \
#     --project $PROJECT \
#     --zone $ZONE \
#     --cluster $KFAPP_NAME \
#     --accelerator type=nvidia-tesla-k80,count=4 \
#     --num-nodes 1 \
#     --machine-type n1-highmem-8 \
#     --disk-size=220GB \
#     --scopes cloud-platform \
#     --verbosity error

# # Add a daemonset that will detect nodes with nvidia hardware and install nvidia drivers for them.
# kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/stable/nvidia-driver-installer/cos/daemonset-preloaded.yaml
# --------------------------

gcloud beta container clusters update $KFAPP_NAME \
    --project $PROJECT \
    --zone $ZONE \
    --enable-autoprovisioning \
    --max-cpu 48 \
    --max-memory 224 \
    --max-accelerator type=nvidia-tesla-k80,count=4 \
    --verbosity error

# Port forwarding reverse proxy to ambassador 
# kubectl port-forward -n kubeflow svc/ambassador 8080:80


# install ksonnet locally
. $COMMON_BASH_FILES_PATH/install-ksonnet-locally.sh

# Create a cloud storage bucket that will hold the trained model.
gsutil.cmd mb -c regional -l $REGION gs://${BUCKET_NAME}

# Install kubeflow pipelines SDK globally as conda can't find it.
pip install kfp

# INstall yaml support for python
conda install pyyaml -y

curl -O https://raw.githubusercontent.com/kubeflow/examples/master/github_issue_summarization/pipelines/example_pipelines/gh_summ.py

python gh_summ.py