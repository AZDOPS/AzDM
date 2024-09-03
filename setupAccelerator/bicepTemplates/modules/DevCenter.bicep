
@description('Name of DevCenter. Required')
param name string

@description('Name of project to create in DevCenter. If not set, will be "{DevCenter Name}-MDPProject"')
param projectName string = ''

@description('Location. If not set, will be same as resource group.')
param location string = resourceGroup().location

var devCenterProjectName = empty(projectName) ? '${name}-MDPProject' : projectName

resource devCenter 'Microsoft.DevCenter/devcenters@2024-07-01-preview' = {
  name: name
  location: location
}

resource devCenterProjects 'Microsoft.DevCenter/projects@2024-07-01-preview' = {
  name: devCenterProjectName
  location: location
  properties: {
    devCenterId: devCenter.id
  }
}


output DevCenterProjectId string = devCenterProjects.id
