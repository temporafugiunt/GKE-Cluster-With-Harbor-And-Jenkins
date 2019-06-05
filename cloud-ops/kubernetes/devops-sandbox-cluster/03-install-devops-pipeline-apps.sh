#!/bin/bash

# 
#   Installs Istio, cert-manager, Harbor, and Jenkins into the kubernetes cluster.
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

# Initialize tiller in the new cluster (Tiller goes away with V3 of helm),
helm init --service-account tiller

echo 'Sleeping for 30 seconds after installing Tiller'
sleep 30s

# Install all the Custom Resource Definitions for Istio.
kubectl create namespace istio-system
helm template $ISTIO_INSTALL_DIR/install/kubernetes/helm/istio-init --name instio-init --namespace istio-system --set certmanager.enabled=true | kubectl apply -f -
# To Verify All CRDs - 53 without cert-manager, 58 with:
#   kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l

echo 'Sleeping for 30 seconds after installing Istio CRDs'
sleep 30s

# Install demo functionality into cluster for full look at all Istio components.
helm template $ISTIO_INSTALL_DIR/install/kubernetes/helm/istio --name instio --namespace istio-system --values $ISTIO_INSTALL_DIR/install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl apply -f -

# # Set necessary secrets as environment variables.
# # . ../../azure/devops-sandbox-cluster/.secrets/set-sql-server-environment-variables.sh
# . $CLUSTER_FILES_PATH/.secrets/set-external-resources-environment-variables.sh

# # Need to wait till tiller is available.
# helm install stable/nginx-ingress --name nginx-ingress --namespace kube-system --set controller.hostNetwork=true --set controller.kind=DaemonSet
# helm install stable/cert-manager --name cert-manager --namespace kube-system --set ingressShim.defaultIssuerName=letsencrypt-staging-clusteri --set ingressShim.defaultIssuerKind=ClusterIssuer

# kubectl create -f $COMMON_FILES_PATH/ClusterIssuer/letsencrypt-staging.yaml
# kubectl create -f $COMMON_FILES_PATH/ClusterIssuer/letsencrypt-production.yaml

# # Create a network tester for testing the internal network of the cluster.
# kubectl create -f $COMMON_FILES_PATH/Deployment/busyBoxTester.yaml

# # Setup harbor
# git clone https://github.com/goharbor/harbor-helm harbor-helm

# cd ./harbor-helm

# # Commits from 11-21-2018 broke persistence, need to investigate values.yaml changes in future.
# git checkout -b 1.0.0 origin/1.0.0

# helm dependency update
# helm upgrade --install --namespace build harbor -f $CLUSTER_FILES_PATH/Deployment/harbor-helm-values.yaml --set harborAdminPassword=$HARBOR_ADMIN_USER_PASSWORD --set secretKey=$HARBOR_SECRET_KEY --set database.internal.password=$HARBOR_ADMIN_USER_PASSWORD .
# # kubectl exec -it harbor-harbor-database-0 -n build usr/bin/bash
# #   psql -U postgres
# #   \l
# #   \dl

# echo 'Sleeping for 30 seconds'
# sleep 30s




# # helm delete --purge freeby-jenkins
# helm upgrade --install --namespace build freeby-jenkins -f $CLUSTER_FILES_PATH/Deployment/freeby-jenkins-values.yaml --set Master.AdminUser=$JENKINS_ADMIN_USER --set Master.AdminPassword=$JENKINS_ADMIN_USER_PASSWORD stable/jenkins

