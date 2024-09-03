@description('Name of virtual network. Required')
param vnetName string

@description('Name of subnet. Required')
param subnetName string

@description('Location. If not set, will be same as resource group.')
param location string = resourceGroup().location

@description('Vnet address prefixes. if not set will be 10.0.0.0/16')
param vnetAddressPrefixes array = [
  '10.0.0.0/16'
]

@description('Subnet address prefix. if not set will be 10.0.1.0/24')
param subnetAddressPrefix string = '10.0.1.0/24'

@description('Security rules to be added to the NSG.')
param securityRules array = []

@description('Principal ID (App Id) of the DevOpsInfrastructure service principal')
param principalId string

var nsgName = '${vnetName}-${subnetName}-nsg'


// Default NSG rules
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

resource MDPNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
  }
}

resource DevOps 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: MDPNetwork
  name: subnetName
  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }
    addressPrefix: subnetAddressPrefix
    delegations: [
      {
        name: 'Microsoft.DevOpsInfrastructure.pools'
        properties: {
          serviceName: 'Microsoft.DevOpsInfrastructure/pools'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: union(securityRules, defaultSecurityRules)
  }
}

@description('This is the Network contributor role definition, needed by MDP')
resource readerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

resource readerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: MDPNetwork
  name: guid(MDPNetwork.id, principalId, readerRoleDefinition.id)
  properties: {
    principalId: principalId
    roleDefinitionId: readerRoleDefinition.id
    principalType: 'ServicePrincipal'
  }
}

@description('This is the reader role definition, needed by MDP')
resource NWContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: MDPNetwork
  name: guid(MDPNetwork.id, principalId, NWContributorRoleDefinition.id)
  properties: {
    principalId: principalId
    roleDefinitionId: NWContributorRoleDefinition.id
    principalType: 'ServicePrincipal'
  }
}

output SubnetId string = DevOps.id
