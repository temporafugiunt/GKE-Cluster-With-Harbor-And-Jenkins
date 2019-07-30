#!/bin/bash
#
#   Installs a MetalLB configmap representing the IP addresses that can be used in a Layer 2 configuration of 
#   MetalLB.
#
#   IP_ADDRESS_RANGE =  The IP v4 address ranges that MetalLB can hand out in its capacity as the cluster Load Balancer.
#

sed "s/IP_ADDRESS_RANGE/$IP_ADDRESS_RANGE/g" $COMMON_FILES_PATH/ConfigMap/metallb-configmap.yaml | kubectl apply -f -