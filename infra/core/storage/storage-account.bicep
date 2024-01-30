metadata description = 'Creates a secure Azure storage account.'
param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([
  'Cool'
  'Hot'
  'Premium' ])
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = false
param allowCrossTenantReplication bool = true
param allowSharedKeyAccess bool = false
param containers array = []
param defaultToOAuthAuthentication bool = false
param deleteRetentionPolicy object = {}
@allowed([ 'AzureDnsZone', 'Standard' ])
param dnsEndpointType string = 'Standard'
param kind string = 'StorageV2'
param minimumTlsVersion string = 'TLS1_2'
param supportsHttpsTrafficOnly bool = true
@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Disabled'
param sku object = { name: 'Standard_LRS' }
// network config
param vnetSubscriptionId string
param vnetResourceGroupName string
param vnetName string
param subnetName string
//param privateEndpointBlobStorageName string = 'pve-stor'

///
// Resources
///

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = if (!empty(vnetName)) {
  scope: resourceGroup(
    vnetSubscriptionId, vnetResourceGroupName
  )
  name: vnetName
  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

var networkAcls = (empty(vnetName)) ? {
  bypass: 'AzureServices'
  virtualNetworkRules: []
  ipRules: []
  //defaultAction: 'Allow'
} : {
  bypass: 'AzureServices'
  // virtualNetworkRules: [
  //   {
  //     id: vnet::subnet.id
  //     action: 'Allow'
  //   }
  // ]
  defaultAction: 'Deny'
}

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: sku

  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    dnsEndpointType: dnsEndpointType
    minimumTlsVersion: minimumTlsVersion
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
  }

  resource blobServices 'blobServices' = if (!empty(containers)) {
    name: 'default'
    properties: {
      deleteRetentionPolicy: deleteRetentionPolicy
    }
    resource container 'containers' = [for container in containers: {
      name: container.name
      properties: {
        publicAccess: contains(container, 'publicAccess') ? container.publicAccess : 'None'
      }
    }]
  }
}

output name string = storage.name
output primaryEndpoints object = storage.properties.primaryEndpoints
output vnet object = vnet
output subnet object = vnet::subnet
output storageAccount object = storage
output storageid string = storage.id
