#!/bin/bash
# This retrieves the latest released version of ksonnet (which is before discontinuation was v0.13.1).

KS_VER=0.13.1
KS_BIN=ks_${KS_VER}_windows_amd64

curl -L https://github.com/ksonnet/ksonnet/releases/download/v${KS_VER}/${KS_BIN}.zip > $CLUSTER_FILES_PATH/${KS_BIN}.zip
export KSONNET_INSTALL_DIR=$CLUSTER_FILES_PATH/$KS_BIN
export PATH=$PATH:$KSONNET_INSTALL_DIR

unzip $CLUSTER_FILES_PATH/${KS_BIN}.zip -d $CLUSTER_FILES_PATH