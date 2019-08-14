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

# Create a cloud storage bucket that will hold the trained model.
gsutil.cmd mb -c regional -l $REGION gs://${BUCKET_NAME}-xgboost

curl -O https://raw.githubusercontent.com/kubeflow/pipelines/master/samples/core/xgboost_training_cm/xgboost_training_cm.py

conda create --name kubeflow-xgboost -y
. activate kubeflow-xgboost

# not available from conda repos
pip install kfp -y

# conda deactivate
python xgboost_training_cm.py

