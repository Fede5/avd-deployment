// modules/hostpool.bicep
@description('Nombre del AVD Host Pool.')
param hostPoolName string

@description('Ubicación para el Host Pool.')
param location string

@description('Nombre descriptivo (Friendly Name) del Host Pool.')
param friendlyName string = hostPoolName

@description('Tipo de Host Pool: Pooled o Personal.')
@allowed([
  'Pooled'
  'Personal'
])
param hostPoolType string = 'Pooled'

@description('Algoritmo de balanceo de carga: BreadthFirst o DepthFirst.')
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param loadBalancerType string = 'BreadthFirst'

@description('Número máximo de sesiones concurrentes por Session Host (solo para Pooled).')
param maxSessionLimit int = 10

@description('Propiedades RDP personalizadas (ej: "audiocapturemode:i:1;camerastoredirect:s:*"). Déjalo vacío si no necesitas.')
param customRdpProperties string = ''

@description('Indica si este Host Pool es para validación antes de producción.')
param validationEnvironment bool = false

@description('ID del Log Analytics Workspace para enviar diagnósticos.')
param logAnalyticsWorkspaceId string

@description('Tags para aplicar al recurso.')
param tags object = {}

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' = {
  name: hostPoolName
  location: location
  tags: tags
  properties: {
    friendlyName: friendlyName
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    maxSessionLimit: (hostPoolType == 'Pooled') ? maxSessionLimit : null // Solo aplica a Pooled
    customRdpProperty: customRdpProperties
    validationEnvironment: validationEnvironment
    // Aquí podrías añadir más configuraciones como SsoContext, StartVMOnConnect, etc.
  }
}

// Configuración de Diagnóstico para el Host Pool
resource hostPoolDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: hostPool // Asocia la configuración al Host Pool
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs' // Puedes ser más específico si lo deseas
        enabled: true
        retentionPolicy: {
          enabled: false // La retención se maneja en el LA Workspace
          days: 0
        }
      }
      // Puedes agregar 'metrics' si es necesario
    ]
  }
}

@description('ID del Host Pool creado.')
output hostPoolId string = hostPool.id

@description('Nombre del Host Pool creado.')
output hostPoolResourceName string = hostPool.name