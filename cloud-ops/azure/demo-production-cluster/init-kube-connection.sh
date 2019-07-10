export DEST_PATH=$(pwd)
cd /c/dev/freeby/GKE-Cluster-With-Harbor-And-Jenkins/cloud-ops/azure/demo-production-cluster/terraform
mkdir -p $DEST_PATH/.secrets
echo "$(terraform output kube_config)" > $DEST_PATH/.secrets/kube_config
export KUBECONFIG=$DEST_PATH/.secrets/kube_config
export CLUSTER_NAME=gcs-demo-prod
cd $DEST_PATH
