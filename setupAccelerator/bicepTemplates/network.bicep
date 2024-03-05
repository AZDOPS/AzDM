param vnetNamePrefix string = 'AzDMVMSS'
param location string = resourceGroup().location
param vnetPrefix array = [
  '10.1.0.0/16'
]
param subnetPrefix string = '10.1.0.0/16'

var vnetName = '${vnetNamePrefix}VNet'
var subnetName = '${vnetNamePrefix}subnet'
var nsgName = '${vnetNamePrefix}nsg'

var defaultSecurityRules = [  
  {
    name: 'DenyAllInBound'
    properties: {
      description: 'Deny all inbound traffic'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 4096
      direction: 'Inbound'
    }
  }  
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: defaultSecurityRules
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetPrefix
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
