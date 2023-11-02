param name string
param location string = resourceGroup().location
param tags object = {}
param serviceName string = 'backend'
param appServicePlanId string
@secure()
param appSettings object = {}
param allowedOrigins array = []

module web '../core/host/appservice.bicep' = {
  name: 'web'
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

output SERVICE_WEB_NAME string = web.outputs.name
output uri string = web.outputs.uri
output identityPrincipalId string = web.outputs.identityPrincipalId
