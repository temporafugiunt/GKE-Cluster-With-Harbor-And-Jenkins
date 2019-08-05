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

# Download the exampled files from kubeflow and create a working directory env_var for the correct project.
git clone https://github.com/kubeflow/examples.git kubeflow_eamples
export WORKING_DIR=${ORIG_DIR}/kubeflow_examples/mnist

# Create a cloud storage bucket that will hold the trained model.
gsutil.cmd mb -c regional -l $REGION gs://${BUCKET_NAME}

echo "Place this code in a newly constructed Jupyter notebook cell in the kubeflow cluster as documented by https://www.kubeflow.org/docs/gke/gcp-e2e/\n\n"

cat ${WORKING_DIR}/model.py
