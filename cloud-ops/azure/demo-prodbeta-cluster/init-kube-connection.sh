export DEST_PATH=$(pwd)
cd /c/dev/Maven/demo-clusters/cloud-ops/azure/demo-prodbeta-cluster/terraform
mkdir -p $DEST_PATH/.secrets
echo "$(terraform output kube_config)" > $DEST_PATH/.secrets/kube_config
export KUBECONFIG=$DEST_PATH/.secrets/kube_config
export CLUSTER_NAME=prodbeta-cluster
cd $DEST_PATH
