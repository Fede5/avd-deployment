// modules/loganalytics.bicep
@description('Nombre del Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

@description('Ubicación para el Log Analytics Workspace.')
param location string = resourceGroup().location

@description('Tags para aplicar al recurso.')
param tags object = {}

@description('SKU del Log Analytics Workspace.')
param sku string = 'PerGB2018' // SKU común, puedes ajustarlo

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 30 // Ajusta la retención según tus necesidades
  }
}

@description('ID del Log Analytics Workspace creado.')
output logAnalyticsWorkspaceId string = logAnalytics.id