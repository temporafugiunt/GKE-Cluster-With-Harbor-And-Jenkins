#!/bin/bash

# 
#   Installs Jenkins into the kubernetes cluster along with the Istio components necessary to expose the sandbox apps.
#   Makes them externally available by HTTPS protected with TLS encryption and a cert retained through Let's Encrypt.
#    
#   Authors: James Eby
#

# Set the certificate issuer used for applications installed below
export CERT_ISSUER=letsencrypt-production-issuer

# Install Jenkins instance and all the Istio specific objects not supported by Helm chart to expose Jenkins properly
# to the outside world not using Ingress.
export OBJECT_BASE_NAME=pipelines-devsandbox
export DOMAIN_NAME=dev-pipelines.devsandbox.co
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

# # Setup the Istio Gateway tying https to sandboxapp.ddns.net via a lets encrypt cert.
export OBJECT_BASE_NAME=apps-devsandbox
export DOMAIN_NAME=dev-apps.devsandbox.co
. $COMMON_BASH_FILES_PATH/setup-cert-and-named-gateway-for-dns-name.sh

kubectl create secret generic sandboxapps-env-secrets -n dev \
    --from-literal=SANDBOXAPPS_DNS_NAME=$DOMAIN_NAME

kubectl create secret generic sandboxapps-env-secrets -n qa \
    --from-literal=SANDBOXAPPS_DNS_NAME=$DOMAIN_NAME

cd $CLUSTER_FILES_PATH