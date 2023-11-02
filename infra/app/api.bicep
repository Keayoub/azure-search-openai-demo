param name string
param location string = resourceGroup().location
param tags object = {}

param allowedOrigins array = []
param applicationInsightsName string = ''
param appServicePlanId string
@secure()
param appSettings object = {}
param keyVaultName string
param serviceName string = 'api'
param storageAccountName string

module functionapp '../core/host/functions.bicep' = {
  name: '${serviceName}-function'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    allowedOrigins: allowedOrigins
    alwaysOn: true
    appSettings: union(appSettings, {
        WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        WEBSITE_CONTENTSHARE: name
        CONTENT_INDEX_CATEGORY: 'FunctionApp'
        USE_LOCAL_PDF_PARSER: false        
      })
    applicationInsightsName: applicationInsightsName
    appServicePlanId: appServicePlanId
    keyVaultName: keyVaultName
    runtimeName: 'python'
    runtimeVersion: '3.11'
    storageAccountName: storageAccountName
    scmDoBuildDuringDeployment: true
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

output SERVICE_PRINCIPAL_ID string = functionapp.outputs.identityPrincipalId
output SERVICE_API_NAME string = functionapp.outputs.name
output SERVICE_API_URI string = functionapp.outputs.uri
