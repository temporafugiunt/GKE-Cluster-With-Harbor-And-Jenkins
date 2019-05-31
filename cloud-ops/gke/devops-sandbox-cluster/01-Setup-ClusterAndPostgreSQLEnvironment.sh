#!/bin/bash
# This bash script creates a kubernetes cluster in whatever GCP project is selected at login.

gcloud init

export CLUSTER_NAME='devops-sandbox-k8s'
export CLUSTER_ZONE='central1-c'

# Creat the new cluster
gcloud container clusters create $CLUSTER_NAME --num-nodes 2  --zone $CLUSTER_ZONE --machine-type=n1-highmem-2 --addons=HttpLoadBalancing,HorizontalPodAutoscaling,KubernetesDashboard,Istio  --enable-ip-alias --enable-autorepair --enable-autoupgrade

# Get the proper credentials with which to work with kubectl
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE

# TODO - Setup PostgreSQL services

# TODO - Execute main kuberenetes setup found in ../kubernetes/devops-sandbox-cluster
