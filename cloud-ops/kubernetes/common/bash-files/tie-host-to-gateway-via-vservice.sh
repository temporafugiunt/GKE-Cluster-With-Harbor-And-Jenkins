#!/bin/bash
#
#   Ties a host defined in a given namespace exposed with a given Port to a gateway
#   via a VirtualService definition. 
#
#   OBJECT_BASE_NAME = The base name prefix used when defining object names.
#   DOMAIN_NAME      = The domain name that we are attempting to create a certificate and gateway for.
#   HOST_NAMESPACE   = The namespace the host can be found in.
#   HOST_NAME        = The host to expose, usually a service name.
#   HOST_PORT        = The host port to expose, usuall a service port.

sed "s/OBJECT_BASE_NAME/$OBJECT_BASE_NAME/g" $COMMON_FILES_PATH/VirtualService/virtual-service-no-subdomain-template.yaml | \
    sed --expression="s/DOMAIN_NAME/$DOMAIN_NAME/g" | \
    sed --expression="s/HOST_NAMESPACE/$HOST_NAMESPACE/g" | \
    sed --expression="s/HOST_NAME/$HOST_NAME/g" | \
    sed --expression="s/HOST_PORT/$HOST_PORT/g" | kubectl apply -f -