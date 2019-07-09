#requires -Version 5.1
$ErrorActionPreference = "Stop"

$commandPath = Split-Path -parent $PSCommandPath

Set-Location $commandPath

# Clone upstream jenkins helm chart as we need version newer than what
# is available in stable/jenkins for 
git clone https://github.com/freebyTech/CloudLibs CloudLibs
$commonPsModulesPath = Resolve-Path -Path "$commandPath\CloudLibs\ps-functions\azure"

Import-Module "$commonPsModulesPath\New-ClusterByTerraform.psm1"

$clusterName = 'gcs-prod'

$newClusterInfo = New-ClusterByTerraform -ClusterName $clusterName -ClusterPath $commandPath -AgentCount 2 -VmSize 'Standard_B2s' -ClusterLocation 'Central US' -DiskSize 64