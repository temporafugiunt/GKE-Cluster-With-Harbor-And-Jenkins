#!/bin/bash
# This bash script creates a kubernetes cluster with kubeflow and all services installed in whatever GCP project is selected at login.

# Run if you need to init the SDK and set the current user and the current project. This can be commented out if not needed.
gcloud auth application-default login

export CLUSTER_FILES_PATH=$(pwd)
export CLIENT_ID=825376869634-8ev106d3vvg4niq9cqd3jolsmgsg9s78.apps.googleusercontent.com
export CLIENT_SECRET=SpkOo08lgzFo-kaFN2mx2iVK
export PROJECT=mwe-james-eby
export ZONE=us-east1-b

# # Set necessary secrets as environment variables.
#. ./.secrets/set-external-resources-environment-variables.sh

# Set default Zone
gcloud config set compute/zone $ZONE

export KF_VERSION=v0.6.1
export KF_DOWNLOAD=https://github.com/kubeflow/kubeflow/releases/download/$KF_VERSION/kfctl_"$KF_VERSION"_darwin.tar.gz

echo "Downloading from $KF_DOWNLOAD"
curl -L $KF_DOWNLOAD > $CLUSTER_FILES_PATH/kfctl_"$KF_VERSION"_darwin.tar.gz
tar -xvf $CLUSTER_FILES_PATH/kfctl_"$KF_VERSION"_darwin.tar.gz

# Add kfctl to PATH, to make the kfctl binary easier to use.
export PATH=$PATH:$(pwd)
export KFAPP="kf-pipelines"

echo "Running kfctl to create GKE cluster $KFAPP in project $PROJECT"
kfctl init $KFAPP --platform gcp --project $PROJECT

cd $KFAPP
kfctl generate all -V
# kfctl apply all -V

# cd ../../../cluster-ops/kubernetes/demo-kubeflow-gke/

# kubectl -n kubeflow get  all

echo "You should be able to access https://${KFAPP}.endpoints.${PROJECT}.cloud.goog/ within 20 minutes"