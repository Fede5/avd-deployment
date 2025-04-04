param location string = resourceGroup().location
param hostPoolName string
param workspaceName string
param vmCount int = 2
param adminUsername string
@secure()
param adminPassword string

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' = {
  name: hostPoolName
  location: location
  properties: {
    friendlyName: hostPoolName
    hostPoolType: 'Pooled'
    loadBalancerType: 'DepthFirst'
    maxSessionLimit: 10
  }
}

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-07-12' = {
  name: '${hostPoolName}-appgroup'
  location: location
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPool.id
    friendlyName: '${hostPoolName}-appgroup'
  }
}

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2021-07-12' = {
  name: workspaceName
  location: location
  properties: {
    friendlyName: workspaceName
    description: 'Workspace for AVD deployment'
  }
}