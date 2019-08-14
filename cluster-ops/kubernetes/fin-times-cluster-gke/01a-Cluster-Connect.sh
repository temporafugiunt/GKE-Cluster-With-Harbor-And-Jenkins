#!/bin/bash

#
# This bash script connects the user to the existing cluster already created in 01-Setup-KubeflowResources.sh
#

# Set necessary secrets as environment variables.
. $CLUSTER_FILES_PATH/../../../cloud-ops/gke/fin-times-cluster-gke/.secrets/set-external-resources-environment-variables.sh

# gcloud init
# gcloud auth application-default login

# Get the proper credentials with which to work with kubectl
gcloud container clusters get-credentials $KFAPP_NAME --zone $ZONE --project $PROJECT

# set default context to kubeflow for this context.
kubectl config set-context $(kubectl config current-context) --namespace=kubeflow

# set default zone to cluster zone.
gcloud config set compute/zone ${ZONE}

echo "You should be able to access kubeflow at https://${KFAPP_NAME}.endpoints.${PROJECT}.cloud.goog/"