#!/bin/bash
#
#   Creates a Certificate resource for a given DNS name that istio and cert-manager work with to produce a 
#   new private certificate from the defined issuer and also creates a Gateway that 
#   associates that certificate resource to the passed DNS name. VirtualServices can then associate with that
#   gateway to tie to that DNS with TLS enabled. The following environment variables are used:
#
#   OBJECT_NAME_NAME =  The base name prefix used when defining object names.
#   DOMAIN_NAME =       The domain name that we are attempting to create a certificate and gateway for.
#   CERT_ISSUER =       The Issuer resource to use that will negotiate the certificate creation, must be 
#                       an Issuer defined in the istio-system namespace.
#

sed "s/OBJECT_BASE_NAME/$OBJECT_BASE_NAME/g" $COMMON_FILES_PATH/Certificate/single-domain-certificate-template.yaml | \
    sed --expression="s/DOMAIN_NAME/$DOMAIN_NAME/g" | \
    sed --expression="s/CERT_ISSUER/$CERT_ISSUER/g" | kubectl apply -f -

sed "s/OBJECT_BASE_NAME/$OBJECT_BASE_NAME/g" $COMMON_FILES_PATH/Gateway/single-domain-certificate-template.yaml | \
    sed --expression="s/DOMAIN_NAME/$DOMAIN_NAME/g" | kubectl apply -f -