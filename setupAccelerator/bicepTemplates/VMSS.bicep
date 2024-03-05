param adminUserName string
@secure()
param adminPassword string
param subnetId string

param vmssName string = 'AzDMVMSS'
param location string = resourceGroup().location
param computerNamePrefix string = vmssName

resource VMSS 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: vmssName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard_DS1_v2'
    tier: 'Standard'
    capacity: 0
  }
  properties: {
    orchestrationMode: 'Uniform'
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: computerNamePrefix
        adminUsername: adminUserName
        adminPassword: adminPassword
        linuxConfiguration: {
          disablePasswordAuthentication: false
        }
      }
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          diskSizeGB: 30
        }
        imageReference: {
          publisher: 'canonical'
          offer: '0001-com-ubuntu-server-focal'
          sku: '20_04-lts-gen2'
          version: 'latest'
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${vmssName}-vnet-nic01'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              dnsSettings: {
                dnsServers: []
              }
              enableIPForwarding: false
              ipConfigurations: [
                {
                  name: '${vmssName}-vnet-nic01-defaultIpConfiguration'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnetId
                    }
                    privateIPAddressVersion: 'IPv4'
                  }
                }
              ]
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
  }
}

output idetity string = VMSS.identity.principalId
