#!/bin/bash

# 
#   Installs nginx ingress, cert manager, harbor, and jenkins into the kubernetes cluster.
#    
#   Authors: James Eby
#

export ORIG_DIR=$(pwd)

export CLUSTER_FILES_PATH=$ORIG_DIR
export COMMON_FILES_PATH="$(dirname "$ORIG_DIR")"/common
export COMMON_BASH_FILES_PATH=$COMMON_FILES_PATH/bash-files

# Establishes connection to kubernetes cluster.
. $COMMON_BASH_FILES_PATH/install-helm-locally.sh
. $COMMON_BASH_FILES_PATH/install-istio-locally.sh

helm init --service-account tiller

echo 'Sleeping for 30 seconds'
sleep 30s

# Set necessary secrets as environment variables.
# . ../../azure/devops-sandbox-cluster/.secrets/set-sql-server-environment-variables.sh
. $CLUSTER_FILES_PATH/.secrets/set-external-resources-environment-variables.sh

# Need to wait till tiller is available.
helm install stable/nginx-ingress --name nginx-ingress --namespace kube-system --set controller.hostNetwork=true --set controller.kind=DaemonSet
helm install stable/cert-manager --name cert-manager --namespace kube-system --set ingressShim.defaultIssuerName=letsencrypt-staging-clusteri --set ingressShim.defaultIssuerKind=ClusterIssuer

kubectl create -f $COMMON_FILES_PATH/ClusterIssuer/letsencrypt-staging.yaml
kubectl create -f $COMMON_FILES_PATH/ClusterIssuer/letsencrypt-production.yaml

# Create a network tester for testing the internal network of the cluster.
kubectl create -f $COMMON_FILES_PATH/Deployment/busyBoxTester.yaml

# Setup harbor
git clone https://github.com/goharbor/harbor-helm harbor-helm

cd ./harbor-helm

# Commits from 11-21-2018 broke persistence, need to investigate values.yaml changes in future.
git checkout -b 1.0.0 origin/1.0.0

helm dependency update
helm upgrade --install --namespace build harbor -f $CLUSTER_FILES_PATH/Deployment/harbor-helm-values.yaml --set harborAdminPassword=$HARBOR_ADMIN_USER_PASSWORD --set secretKey=$HARBOR_SECRET_KEY --set database.internal.password=$HARBOR_ADMIN_USER_PASSWORD .
# kubectl exec -it harbor-harbor-database-0 -n build usr/bin/bash
#   psql -U postgres
#   \l
#   \dl

echo 'Sleeping for 30 seconds'
sleep 30s




# helm delete --purge freeby-jenkins
helm upgrade --install --namespace build freeby-jenkins -f $CLUSTER_FILES_PATH/Deployment/freeby-jenkins-values.yaml --set Master.AdminUser=$JENKINS_ADMIN_USER --set Master.AdminPassword=$JENKINS_ADMIN_USER_PASSWORD stable/jenkins

