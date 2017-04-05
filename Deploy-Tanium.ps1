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
  $DeploymentSize
)

$ErrorActionPreference = "Stop"

$TemplateFile = './scenarios/tanium/azuredeploy.json'
$TemplateParameterObject = @{
    'deploymentSize' = $DeploymentSize
}
# Login to Azure and select your subscription
Login-AzureRmAccount -SubscriptionId $SubscriptionId | Out-Null

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null

# Deploy Tanium 
New-AzureRmResourceGroupDeployment -Name "TaniumDeploy" `
                                   -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -TemplateParameterObject $TemplateParameterObject
