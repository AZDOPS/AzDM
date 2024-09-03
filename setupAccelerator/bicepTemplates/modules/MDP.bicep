// Parameters
@description('Name of managed DevOps pool. Required')
param name string

@description('Location. If not set, will be same as resource group.')
param location string = resourceGroup().location

@description('ID of user assigned managed identity to connect to MDP pool')
param managedIdentityId string

@description('Azure DevOps organization(s). URL (https://dev.azure.com/<your domain>) and mazimum parallelism is required')
param AzureDevOpsOrganizations azureDevOpsOrg

@description('Well known images (Azure DevOps build host images) to use.')
param images osImages[]

@description('Non Azure DevOps images. Format is similar to "/subscriptions/<subId>/Providers/Microsoft.Compute/Locations/<region>/publishers/microsoftvisualstudio/artifacttypes/vmimage/offers/visualstudio2022/skus/vs-2022-ent-latest-ws2022/versions/latest"')
param standardImages resourceImages[] = []

@description('Resource ID of DEvCenter project.')
param DevCenterProjectResourceId string

@description('Maximum concurrent hosts. Remember to check your quota!')
param maximumConcurrency int = 5

@description('Subnet to connect pool to.')
param subnetId string

@allowed([
  'Stateless'
  'Stateful'
])
param agentProfile string = 'Stateless'

@allowed([
  'StandardSSD'
  'Standard'
  'Premium'
])
param osDiskType string = 'StandardSSD'

param vmSku string = 'Standard_D2ads_v5'

// Custom type declarations
type azureDevOpsOrg = {
  url: string
  parallelism: int
  projects: string[]?
}

type osImages = {
  aliases: string[]?
  buffer: string?
  wellKnownImageName: 'windows-2022/latest' | 'windows-2019/latest' | 'ubuntu-22.04/latest' | 'ubuntu-20.04/latest'
}

type resourceImages = {
  aliases: string[]?
  buffer: string?
  resourceId: string
}

// Variables

var wellKnownImages = [for item in images: {
  aliases: item.?aliases ?? []
  buffer: item.?buffer ?? '*'
  wellKnownImageName: item.wellKnownImageName
}]

var lessKnownImages = [for item in standardImages: {
  aliases: item.?aliases ?? []
  buffer: item.?buffer ?? '*'
  resourceId: item.resourceId
}]

var imagesList = union(wellKnownImages, lessKnownImages)

// Resources
resource MDP 'Microsoft.DevOpsInfrastructure/pools@2024-04-04-preview' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    organizationProfile: {
      kind: 'AzureDevOps'
      organizations: [
        AzureDevOpsOrganizations
      ]
    }
    devCenterProjectResourceId: DevCenterProjectResourceId
    maximumConcurrency: maximumConcurrency
    agentProfile: {
      #disable-next-line BCP225 // I truly dont know why this gives a warning, and quite frankly I dont really care right now.
      kind: agentProfile
    }
    fabricProfile: {
      sku: {
        name: vmSku
      }
      kind: 'Vmss'
      images: imagesList
      storageProfile: {
        osDiskStorageAccountType: osDiskType
      }
      networkProfile: {
        subnetId: subnetId
      }
    }
  }
}
