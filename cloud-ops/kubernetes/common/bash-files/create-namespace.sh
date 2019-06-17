#!/bin/bash
#
#   Creates a new namespace in the active kubernetes cluster.
#
#   NAMESPACE_NAME = The name of the namespace to create.

sed "s/NAMESPACE_NAME/$NAMESPACE_NAME/g" $COMMON_FILES_PATH/Namespace/namespace-template.yaml | kubectl apply -f -