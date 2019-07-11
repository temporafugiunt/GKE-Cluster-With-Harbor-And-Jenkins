#!/bin/bash
# Installs jetstack's cert-manager with proper defaults for a cluster issuer of the name defined in #DEFAULT_CLUSTER_ISSUER

## IMPORTANT: you MUST install the cert-manager CRDs **before** installing the
## cert-manager Helm chart
kubectl apply  -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

## IMPORTANT: create the cert-manager namespace and ensure
## it has an additional label on it in order for the deployment to succeed
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"

## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

## Install the cert-manager helm chart
helm install --name cert-manager --namespace cert-manager jetstack/cert-manager