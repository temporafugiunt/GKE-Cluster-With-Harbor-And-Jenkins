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
helm install $ISTIO_INSTALL_DIR/install/kubernetes/helm/istio-init --name instio-init --namespace istio-system --set certmanager.enabled=true
# To Verify All CRDs - 53 without cert-manager, 58 with:
#   kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l

echo 'Sleeping for 30 seconds after installing Istio CRDs'
sleep 30s

# Install demo functionality into cluster for full look at all Istio components.
helm install $ISTIO_INSTALL_DIR/install/kubernetes/helm/istio --name instio --namespace istio-system \
    --values $ISTIO_INSTALL_DIR/install/kubernetes/helm/istio/values-istio-demo.yaml \
    --set gateways.istio-ingressgateway.sds.enabled=true \
    --set global.k8sIngress.enabled=true \
    --set global.k8sIngress.enableHttps=true \
    --set global.k8sIngress.gatewayName=ingressgateway \
    --set certmanager.enabled=true \
    --set certmanager.email=james.eby@mavenwave.com

echo 'Sleeping for 30 seconds after installing components'
sleep 30s

# Turn on auto istio sidecar injection in build, beta, and production namespaces
kubectl label ns build istio-injection=enabled
kubectl label ns production istio-injection=enabled
kubectl label ns beta istio-injection=enabled

# Add update to default external gateway to remove the invalid https portion of the rule.
kubectl apply -f $COMMON_FILES_PATH/Gateway/istio-cert-manager-gateway.yaml

# Add an HTTP to HTTPS redirector for all communication (needs to exclude Let's Encrypt enquiries on HTTP).
kubectl create ns redirector
kubectl label ns redirector istio-injection=enabled
kubectl apply -n redirector -f $COMMON_FILES_PATH/redirector/redirector.yaml

# Add issuers in istio-system namespace, one for staging tests and the other for production release.
kubectl create -f $COMMON_FILES_PATH/Issuer/letsencrypt-staging.yaml
kubectl create -f $COMMON_FILES_PATH/Issuer/letsencrypt-production.yaml

# Install jetstack cert-manager (integrated into istio installation)
# . $COMMON_BASH_FILES_PATH/helm-install-cert-manager.sh

export LOAD_BALANCER_EXTERNAL_IP=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Your external Load Balancer IP Address is $LOAD_BALANCER_EXTERNAL_IP, please update your DNS records for cluster applciations that will be installed in the next script."




