#
# Deploy_Tanium.ps1
#
param(
  [Parameter(Mandatory=$True)]
  $SubscriptionId,
  [Parameter(Mandatory=$True)]
  $Location, 
  [Parameter(Mandatory=$True)]
  $ResourceGroupName,
  [Parameter(Mandatory=$False)]
  [ValidateSet(
      "3k",
      "10k",
      "35k",
      "75k",
      "150k",
      "400k"
  )]
  $DeploymentSize,
  [Parameter(Mandatory=$True)]
  [pscredential]
  $adminCredential,
  [Parameter(Mandatory=$True)]
  $TSServerNamePrefix
)

$ErrorActionPreference = "Stop"

# If changed this needs to be updated in the taniumserver.SIZE.parameters.json file to match for the compute deployment...
$NetworkingResourceGroupName = 'CORPNET'
$NetworkingTemplateFile = './scenarios/tanium/networking.azuredeploy.json'

$ComputeTemplateFile = './scenarios/tanium/compute.azuredeploy.json'
$ComputeTemplateParameterObject = @{
    'deploymentSize' = $DeploymentSize
    'virtualNetworkName' = 'CORPNET'
    'virtualNetworkResourceGroupName' = $NetworkingResourceGroupName
    'TSServerSubnetName' = 'web'
    'adminUserName' = $adminCredential.UserName
    'adminPassword' = $adminCredential.Password
    'computerNamePrefix' = $TSServerNamePrefix
}
# Login to Azure and select your subscription
Login-AzureRmAccount -SubscriptionId $SubscriptionId | Out-Null

# Create Networking Resource Group
New-AzureRmResourceGroup -Name $NetworkingResourceGroupName -Location $Location -Force | Out-Null

# Deploy Networking
New-AzureRmResourceGroupDeployment -Name "TaniumDeployNetworking" `
                                   -ResourceGroupName $NetworkingResourceGroupName `
                                   -TemplateFile $NetworkingTemplateFile

# Create Tanium Resource Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null

# Deploy Tanium
New-AzureRmResourceGroupDeployment -Name "TaniumDeploy" `
                                   -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $ComputeTemplateFile `
                                   -TemplateParameterObject $ComputeTemplateParameterObject
