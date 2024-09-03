param DevCenterName string
param ManagedIdentityName string
param subnetNameName string
param vnetNameName string
param MDPName string
param ADOUrl string
param MDPImageName osImages[]
param DevOpsInfrastructurePrincipalId string

type osImages = {
  aliases: string[]?
  buffer: string?
  wellKnownImageName: 'windows-2022/latest' | 'windows-2019/latest' | 'ubuntu-22.04/latest' | 'ubuntu-20.04/latest'
}

module DevCenter 'modules/DevCenter.bicep' = {
  name: 'DevCenter'
  params: {
    name: DevCenterName
  }
}

module ManagedIdentity 'modules/ManagedIdentity.bicep' = {
  name: 'ManagedIdentity'
  params: {
    name: ManagedIdentityName
  }
}

module Network 'modules/Network.bicep' = {
  name: 'MDPNetwork'
  params: {
    subnetName: subnetNameName
    vnetName: vnetNameName
    principalId: DevOpsInfrastructurePrincipalId
  }
}

module MDP 'modules/MDP.bicep' = {
  name: 'ManagedDevOpsPool'
  params: {
    name: MDPName
    AzureDevOpsOrganizations: {
      url: ADOUrl
      parallelism: 2
    }
    DevCenterProjectResourceId: DevCenter.outputs.DevCenterProjectId
    managedIdentityId: ManagedIdentity.outputs.managedIdentityId
    
    images: MDPImageName
    subnetId: Network.outputs.SubnetId
  }
}

output identity string = ManagedIdentityName
