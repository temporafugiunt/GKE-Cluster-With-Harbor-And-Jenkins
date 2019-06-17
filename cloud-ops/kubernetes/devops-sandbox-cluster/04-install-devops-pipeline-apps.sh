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
export OBJECT_BASE_NAME=sandboxbuilds-ddns
export DOMAIN_NAME=sandboxbuilds.ddns.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-gateway-for-dns-name.sh

# # helm delete --purge freeby-jenkins
helm upgrade --install --namespace build freeby-jenkins \
    -f $CLUSTER_FILES_PATH/Deployment/freeby-jenkins-values.yaml \
    --set Master.AdminUser=$JENKINS_ADMIN_USER \
    --set Master.AdminPassword=$JENKINS_ADMIN_USER_PASSWORD \
    stable/jenkins

export HOST_NAMESPACE=build
export HOST_NAME=freeby-jenkins
export HOST_PORT=8080
. $COMMON_BASH_FILES_PATH/tie-host-to-gateway-via-vservice.sh


export OBJECT_BASE_NAME=sandboxapp-ddns
export DOMAIN_NAME=sandboxapp.ddns.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-gateway-for-dns-name.sh

kubectl apply -n production -f https://raw.githubusercontent.com/istio/istio/1.1.7/samples/helloworld/helloworld.yaml

# Setup the gateways tying the last cert to helloworld service
export HOST_NAMESPACE=production
export HOST_NAME=helloworld
export HOST_PORT=5000
. $COMMON_BASH_FILES_PATH/tie-host-to-gateway-via-vservice.sh


export OBJECT_BASE_NAME=sandboxregistry-ddns
export DOMAIN_NAME=sandboxregistry.ddns.net
. $COMMON_BASH_FILES_PATH/setup-cert-and-gateway-for-dns-name.sh

# # Create a network tester for testing the internal network of the cluster.
# kubectl create -f $COMMON_FILES_PATH/Deployment/busyBoxTester.yaml

# Setup harbor
git clone https://github.com/goharbor/harbor-helm harbor-helm

cd ./harbor-helm

# Commits from 11-21-2018 broke persistence, need to investigate values.yaml changes in future.
git checkout -b 1.0.0 origin/1.0.0

helm dependency update
helm upgrade --install --namespace build harbor -f $CLUSTER_FILES_PATH/Deployment/harbor-helm-values.yaml --set harborAdminPassword=$HARBOR_ADMIN_USER_PASSWORD --set secretKey=$HARBOR_SECRET_KEY --set database.internal.password=$HARBOR_ADMIN_USER_PASSWORD .
# # kubectl exec -it harbor-harbor-database-0 -n build usr/bin/bash
# #   psql -U postgres
# #   \l
# #   \dl
# Setup the gateways tying the last cert to helloworld service
export HOST_NAMESPACE=build
export HOST_NAME=harbor
export HOST_PORT=80
. $COMMON_BASH_FILES_PATH/tie-host-to-gateway-via-vservice.sh


# echo 'Sleeping for 30 seconds'
# sleep 30s




