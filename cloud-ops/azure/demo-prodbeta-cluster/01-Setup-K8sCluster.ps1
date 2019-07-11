#requires -Version 5.1
$ErrorActionPreference = "Stop"

$commandPath = Split-Path -parent $PSCommandPath

Set-Location $commandPath

# Clone upstream CloudLibs helper library.
git clone https://github.com/freebyTech/CloudLibs CloudLibs
$commonPsModulesPath = Resolve-Path -Path "$commandPath\CloudLibs\ps-functions\azure"

Import-Module "$commonPsModulesPath\New-ClusterByTerraform.psm1"

$clusterName = 'demo-prodbeta-cluster'
$clusterLocation = 'Central US'
$nodeCount = 3

$newClusterInfo = New-ClusterByTerraform -ClusterName $clusterName -ClusterPath $commandPath -AgentCount $nodeCount -VmSize 'Standard_B2ms' -ClusterLocation $clusterLocation -DiskSize 64