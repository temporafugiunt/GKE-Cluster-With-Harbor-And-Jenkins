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

# Turn on auto istio sidecar injection in build and production namespaces
kubectl label ns build istio-injection=enabled
kubectl label ns production istio-injection=enabled

echo 'Sleeping for 30 seconds after installing Istio Services'
sleep 30s

export LOAD_BALANCER_EXTERNAL_IP=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Your external Load Balancer IP Address is $LOAD_BALANCER_EXTERNAL_IP, please update the DNS records for your cluster before continuing."

read -n1 -r -p "Press a key to continue..." key

# # Set necessary secrets as environment variables.
# # . ../../azure/devops-sandbox-cluster/.secrets/set-sql-server-environment-variables.sh
# . $CLUSTER_FILES_PATH/.secrets/set-external-resources-environment-variables.sh

# Add update to default external gateway to remove the invalid https pertion of the rule.
kubectl apply -f $COMMON_FILES_PATH/Gateway/istio-cert-manager-gateway.yaml

# Add issuers in istio-system namespace, one for staging tests and the other for production release.
kubectl create -f $COMMON_FILES_PATH/Issuer/letsencrypt-staging.yaml
kubectl create -f $COMMON_FILES_PATH/Issuer/letsencrypt-production.yaml

# Install jetstack cert-manager
. $COMMON_BASH_FILES_PATH/helm-install-cert-manager.sh

# Set the certificate issuer used for applications installed below
export CERT_ISSUER=letsencrypt-staging-clusteri

# Install dynamic certs and their gateways for services defined later in this script.
export OBJECT_BASE_NAME=sandboxregistry-ddns
export DOMAIN_NAME=sandboxregistry.ddns.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-gateway-for-dns-name.sh

export OBJECT_BASE_NAME=sandboxbuilds-ddns
export DOMAIN_NAME=sandboxbuilds.ddns.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-gateway-for-dns-name.sh

export OBJECT_BASE_NAME=sandboxapp-ddns
export DOMAIN_NAME=sandboxapp.ddns.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-gateway-for-dns-name.sh

kubectl apply -n production -f https://raw.githubusercontent.com/istio/istio/1.1.7/samples/helloworld/helloworld.yaml

# Setup the gateways tying the last cert to helloworld service
export HOST_NAMESPACE=production
export HOST_NAME=helloworld
export HOST_PORT=5000
. $COMMON_BASH_FILES_PATH/tie-host-to-gateway-via-vservice.sh

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

