#!/bin/bash
# This bash script kubeflow cluster creation after manual update of YAML and jinja files based upon:
# https://github.com/kubeflow/examples/tree/master/financial_time_series

kfctl apply all -V

echo "You should be able to access https://${KFAPP}.endpoints.${PROJECT}.cloud.goog/ within 20 minutes"

cd ../../../cluster-ops/kubernetes/fin-times-cluster-gke/