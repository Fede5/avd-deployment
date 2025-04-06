// modules/appgroup.bicep
@description('Nombre del Application Group.')
param applicationGroupName string

@description('Ubicación del Application Group.')
param location string

@description('Nombre descriptivo (Friendly Name) del Application Group.')
param friendlyName string = applicationGroupName

@description('ID del Host Pool al que se asociará este Application Group.')
param hostPoolArmId string

@description('Tipo de Application Group: RemoteApp o Desktop.')
@allowed([
  'RemoteApp'
  'Desktop'
])
param applicationGroupType string = 'Desktop'

@description('ID del Log Analytics Workspace para enviar diagnósticos.')
param logAnalyticsWorkspaceId string

@description('Tags para aplicar al recurso.')
param tags object = {}

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2023-09-05' = {
  name: applicationGroupName
  location: location
  tags: tags
  properties: {
    friendlyName: friendlyName
    hostPoolArmId: hostPoolArmId
    applicationGroupType: applicationGroupType
  }
}

// Configuración de Diagnóstico para el Application Group
resource appGroupDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: applicationGroup
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

@description('ID del Application Group creado.')
output applicationGroupId string = applicationGroup.id