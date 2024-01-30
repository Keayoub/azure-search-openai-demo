// network config
param vnetSubscriptionId string
param vnetResourceGroupName string
param vnetName string
param subnetName string
param pvename string
param linkservice string
param Servicegroupid string
param location string
 
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = if (!empty(vnetName)) {
  scope: resourceGroup(
    vnetSubscriptionId, vnetResourceGroupName
  )
  name: vnetName
  resource subnet 'subnets' existing = {
    name: subnetName
  }
}
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01'=   if (!empty(vnetName)){
  name: pvename
  location: location
  properties: {
    subnet: {
    id: vnet::subnet.id
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: linkservice
          groupIds: [
            Servicegroupid
          ]
        }
        name: pvename
      }
    ]
  }
 
}
