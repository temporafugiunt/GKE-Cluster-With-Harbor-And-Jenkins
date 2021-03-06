#!/bin/bash
# This retrieves the latest released version of helm (which is currently 1.1.7).

ISTIO_VER=1.1.7

curl -L https://github.com/istio/istio/releases/download/$ISTIO_VER/istio-$ISTIO_VER-win.zip > $CLUSTER_FILES_PATH/istio-$ISTIO_VER-win.zip
export ISTIO_INSTALL_DIR=$CLUSTER_FILES_PATH/istio-$ISTIO_VER
export PATH=$PATH:$ISTIO_INSTALL_DIR/bin

unzip $CLUSTER_FILES_PATH/istio-$ISTIO_VER-win.zip -d $CLUSTER_FILES_PATH