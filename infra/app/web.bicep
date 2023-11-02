param name string
param location string = resourceGroup().location
param tags object = {}
param serviceName string = 'backend'
param appServicePlanId string
@secure()
param appSettings object = {}
param allowedOrigins array = []

module webApp '../core/host/appservice.bicep' = {
  name: '${serviceName}-webApp'
  params: {
    name: !empty(name) ? name : '${serviceName}-staticwebapp-module'
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    appServicePlanId: appServicePlanId
    runtimeName: 'python'
    runtimeVersion: '3.11'
    appCommandLine: 'python3 -m gunicorn main:app'
    scmDoBuildDuringDeployment: true
    managedIdentity: true
    appSettings: appSettings    
    allowedOrigins: allowedOrigins
  }
}

output SERVICE_WEB_NAME string = webApp.outputs.name
output uri string = webApp.outputs.uri
output identityPrincipalId string = webApp.outputs.identityPrincipalId
