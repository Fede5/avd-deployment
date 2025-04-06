// modules/workspace.bicep
@description('Nombre del AVD Workspace.')
param workspaceName string

@description('Ubicación del Workspace.')
param location string

@description('Nombre descriptivo (Friendly Name) del Workspace.')
param friendlyName string = workspaceName

@description('Descripción del Workspace.')
param description string = 'Workspace for AVD environment'

@description('Array de IDs de Application Groups a asociar con este Workspace.')
param applicationGroupReferences array // Espera un array con los IDs de los App Groups

@description('ID del Log Analytics Workspace para enviar diagnósticos.')
param logAnalyticsWorkspaceId string

@description('Tags para aplicar al recurso.')
param tags object = {}

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2023-09-05' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    friendlyName: friendlyName
    description: description
    applicationGroupReferences: applicationGroupReferences // Asocia los App Groups
  }
}

// Configuración de Diagnóstico para el Workspace
resource workspaceDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: workspace
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

@description('ID del Workspace creado.')
output workspaceId string = workspace.id