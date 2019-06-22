#!/bin/bash

# 
#   Installs Harbor, and Jenkins into the kubernetes cluster along with a test app and makes the externally available
#   by HTTPS protected with TLS encryption and a cert retained through Let's Encrypt.
#    
#   Authors: James Eby
#

# Set the certificate issuer used for applications installed below
export CERT_ISSUER=letsencrypt-production-issuer

# Install Jenkins instance and all the Istio specific objects not supported by Helm chart to expose Jenkins properly
# to the outside world not using Ingress.
export OBJECT_BASE_NAME=builds-dyndns
export DOMAIN_NAME=builds.sytes.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-named-gateway-for-dns-name.sh

cd $CLUSTER_FILES_PATH

# Clone upstream jenkins helm chart as we need version newer than what
# is available in stable/jenkins for 
git clone https://github.com/helm/charts upstream-helm

cd ./upstream-helm/stable/jenkins

# This is the last commit this script was tested against.
git checkout -b last-tested-commit 991a8bd85277adc27b465519f4fb44d9f3dd2714
helm dependency update

# helm delete --purge jenkins
helm upgrade --install --namespace build jenkins \
    -f $CLUSTER_FILES_PATH/Deployment/standard-jenkins-with-casc.yaml \
    --set master.adminUser=$JENKINS_ADMIN_USER \
    --set master.adminPassword=$JENKINS_ADMIN_USER_PASSWORD \
    --set master.jenkinsUrl=https://$DOMAIN_NAME/ .

# Setup https traffic for sandboxbuilds.ddns.net to go to jenkins service.
export HOST_NAMESPACE=build
export HOST_NAME=jenkins
export HOST_PORT=8080
. $COMMON_BASH_FILES_PATH/tie-host-to-named-gateway-via-vservice.sh

# Redirect http traffic to https.
# export HOST_NAMESPACE=redirector
# export HOST_NAME=redirect
# export HOST_PORT=80
# . $COMMON_BASH_FILES_PATH/tie-host-to-k8s-ingress-gateway-via-vservice.sh

# # Setup the Istio Gateway tying https to sandboxapp.ddns.net via a lets encrypt cert.
export OBJECT_BASE_NAME=apps-dyndns
export DOMAIN_NAME=apps.sytes.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-named-gateway-for-dns-name.sh

# Install the helloworld service into cluster
kubectl apply -n production -f https://raw.githubusercontent.com/istio/istio/1.1.7/samples/helloworld/helloworld.yaml

# Tie hello world service to https gateway.
export HOST_NAMESPACE=production
export HOST_NAME=helloworld
export HOST_PORT=5000
. $COMMON_BASH_FILES_PATH/tie-host-to-named-gateway-via-vservice.sh

# Redirect http traffic to https.
# export HOST_NAMESPACE=redirector
# export HOST_NAME=redirect
# export HOST_PORT=80
# . $COMMON_BASH_FILES_PATH/tie-host-to-k8s-ingress-gateway-via-vservice.sh

# # Create a network tester for testing the internal network of the cluster.
# kubectl create -f $COMMON_FILES_PATH/Deployment/busyBoxTester.yaml

cd $CLUSTER_FILES_PATH

# Setup the Istio Gateway tying https to sandboxregistry.ddns.net via a lets encrypt cert.
export OBJECT_BASE_NAME=registry-dyndns
export DOMAIN_NAME=registry.sytes.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-named-gateway-for-dns-name.sh

# Clone and install harbor into the cluster.
git clone https://github.com/goharbor/harbor-helm harbor-helm

cd ./harbor-helm

# Commits from 11-21-2018 broke persistence, need to investigate values.yaml changes in future.
git checkout -b 1.0.0 origin/1.0.0

helm dependency update
helm upgrade --install --namespace build harbor -f $CLUSTER_FILES_PATH/Deployment/harbor-helm-values.yaml \
    --set harborAdminPassword=$HARBOR_ADMIN_USER_PASSWORD \
    --set secretKey=$HARBOR_SECRET_KEY \
    --set database.internal.password=$HARBOR_ADMIN_USER_PASSWORD .
# # kubectl exec -it harbor-harbor-database-0 -n build usr/bin/bash
# #   psql -U postgres
# #   \l
# #   \dl
# Setup the gateways tying the last cert to helloworld service

# Tie harbor service to https gateway.
export HOST_NAMESPACE=build
export HOST_NAME=harbor
export HOST_PORT=80
. $COMMON_BASH_FILES_PATH/tie-host-to-named-gateway-via-vservice.sh

# Tie harbor service to http standard k8s gateway.
#. $COMMON_BASH_FILES_PATH/tie-host-to-k8s-ingress-gateway-via-vservice.sh

# export HOST_NAMESPACE=redirector
# export HOST_NAME=redirect
# export HOST_PORT=80
# . $COMMON_BASH_FILES_PATH/tie-host-to-k8s-ingress-gateway-via-vservice.sh

# kubectl apply -f $COMMON_FILES_PATH/VirtualService/virtual-service-to-harbor-services.yaml

# echo 'Sleeping for 30 seconds'
# sleep 30s