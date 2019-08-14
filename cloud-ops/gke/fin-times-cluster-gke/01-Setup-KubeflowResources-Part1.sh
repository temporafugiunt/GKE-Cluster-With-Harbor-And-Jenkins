#!/bin/bash
# This bash script creates a kubernetes cluster with kubeflow and all services installed in whatever GCP project is selected at login.

# Run if you need to init the SDK and set the current user and the current project. This can be commented out if not needed.
gcloud auth application-default login

export CLUSTER_FILES_PATH=$(pwd)

# Set necessary secrets as environment variables.
. ./.secrets/set-external-resources-environment-variables.sh

# Set default Zone
gcloud config set compute/zone $ZONE

export KF_VERSION=v0.6.1
export KF_DOWNLOAD=https://github.com/kubeflow/kubeflow/releases/download/$KF_VERSION/kfctl_"$KF_VERSION"_darwin.tar.gz

echo "Downloading from $KF_DOWNLOAD"
curl -L $KF_DOWNLOAD > $CLUSTER_FILES_PATH/kfctl_${KF_VERSION}_darwin.tar.gz
tar -xvf $CLUSTER_FILES_PATH/kfctl_${KF_VERSION}_darwin.tar.gz

# Add kfctl to PATH, to make the kfctl binary easier to use.
export PATH=$PATH:$(pwd)

echo "Running kfctl to create GKE cluster $KFAPP_NAME in project $PROJECT"
kfctl init $KFAPP_NAME --platform gcp --project $PROJECT

cd $KFAPP_NAME
kfctl generate all -V



kfctl apply all -V

echo "You should be able to access https://${KFAPP}.endpoints.${PROJECT}.cloud.goog/ within 20 minutes"

cd ../../../cluster-ops/kubernetes/demo-kubeflow-gke/