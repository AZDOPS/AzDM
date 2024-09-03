@description('Name of managed identity. Required')
param name string

@description('Location. If not set, will be same as resource group.')
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location:location
}

output managedIdentityId string = managedIdentity.id
