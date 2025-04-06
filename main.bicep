// avd-deployment/main.bicep
@description('Prefijo para nombrar recursos (ej: "avd-prod", "avd-dev").')
param prefix string

@description('Entorno (ej: "dev", "qa", "prod"). Usado en tags.')
param environment string = 'dev'

@description('Ubicación principal para los recursos AVD.')
param location string = resourceGroup().location

// *** ACTUALIZADO: commonTags con más detalles y valores por defecto (serán sobreescritos por pipeline) ***
@description('Tags comunes para aplicar a todos los recursos de infraestructura.')
param commonTags object = {
  environment: environment
  project: 'AVD Deployment ${prefix}'
  owner: 'ChangeMe' // Proporcionado por el pipeline
  costCenter: 'ChangeMe' // Proporcionado por el pipeline
  applicationName: 'AVD Core Infrastructure' // Proporcionado por el pipeline
  creationDate: 'ChangeMe' // Proporcionado por el pipeline
  automationTool: 'AzureDevOps-Bicep' // Proporcionado por el pipeline
}

@description('Nombre para el Log Analytics Workspace. Se deriva del prefijo si no se especifica.')
param logAnalyticsWorkspaceName string = '${prefix}-loganalytics'

@description('Nombre para el Host Pool. Se deriva del prefijo.')
param hostPoolName string = '${prefix}-hp'

@description('Nombre para el Desktop Application Group. Se deriva del prefijo.')
param applicationGroupName string = '${prefix}-dag' // DAG for Desktop Application Group

@description('Nombre para el Workspace. Se deriva del prefijo.')
param workspaceName string = '${prefix}-ws'

@description('Tipo de Host Pool (Pooled/Personal).')
@allowed(['Pooled', 'Personal'])
param hostPoolType string = 'Pooled'

@description('Algoritmo de balanceo de carga (BreadthFirst/DepthFirst).')
@allowed(['BreadthFirst', 'DepthFirst'])
param loadBalancerType string = 'BreadthFirst'

@description('Límite máximo de sesiones por host (si es Pooled).')
param maxSessionLimit int = 10

// --- Módulo Log Analytics ---
module logAnalytics 'modules/loganalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location // Podría ser una ubicación diferente si centralizas logs
    tags: commonTags // Aplica tags comunes
  }
}

// --- Módulo Host Pool ---
module hostPool 'modules/hostpool.bicep' = {
  name: 'hostPoolDeployment'
  params: {
    hostPoolName: hostPoolName
    location: location
    friendlyName: 'Host Pool ${prefix}'
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    maxSessionLimit: maxSessionLimit
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId // Pasa el ID del LA creado
    tags: commonTags // Aplica tags comunes
    // customRdpProperties: '' // Descomenta y ajusta si necesitas propiedades RDP
    // validationEnvironment: (environment == 'dev') // Ejemplo: Marcar 'dev' como validación
  }
}

// --- Módulo Application Group (Desktop) ---
module appGroup 'modules/appgroup.bicep' = {
  name: 'appGroupDeployment'
  dependsOn: [
    hostPool // Depende de que el Host Pool exista
  ]
  params: {
    applicationGroupName: applicationGroupName
    location: location
    friendlyName: 'Desktop Access for ${prefix}'
    hostPoolArmId: hostPool.outputs.hostPoolId // Pasa el ID del Host Pool creado
    applicationGroupType: 'Desktop'
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId // Pasa el ID del LA creado
    tags: commonTags // Aplica tags comunes
  }
}

// --- Módulo Workspace ---
module workspace 'modules/workspace.bicep' = {
  name: 'workspaceDeployment'
  dependsOn: [
    appGroup // Depende de que el Application Group exista
  ]
  params: {
    workspaceName: workspaceName
    location: location
    friendlyName: 'Workspace ${prefix}'
    description: 'AVD Workspace for ${environment} environment'
    applicationGroupReferences: [ // Pasa el ID del App Group creado como un array
      appGroup.outputs.applicationGroupId
    ]
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId // Pasa el ID del LA creado
    tags: commonTags // Aplica tags comunes
  }
}

// --- Salidas (Outputs) ---
@description('ID del Host Pool creado.')
output deployedHostPoolId string = hostPool.outputs.hostPoolId

@description('Nombre del Host Pool creado (útil para obtener token).')
output deployedHostPoolName string = hostPool.outputs.hostPoolResourceName

@description('ID del Desktop Application Group creado.')
output deployedAppGroupId string = appGroup.outputs.applicationGroupId

@description('ID del Workspace creado.')
output deployedWorkspaceId string = workspace.outputs.workspaceId

@description('ID del Log Analytics Workspace.')
output deployedLogAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId