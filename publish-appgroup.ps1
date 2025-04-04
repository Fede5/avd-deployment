$subscriptionId = "<your-subscription-id>"
$resourceGroup = "rg-avd"
$workspaceName = "avd-workspace"
$appGroupName = "avd-hostpool-appgroup"

Connect-AzAccount
Set-AzContext -SubscriptionId $subscriptionId

New-AzWvdWorkspace -Name $workspaceName -ResourceGroupName $resourceGroup -Location "East US" -FriendlyName $workspaceName

Register-AzWvdApplicationGroup -ResourceGroupName $resourceGroup `
  -WorkspaceName $workspaceName `
  -ApplicationGroupName $appGroupName