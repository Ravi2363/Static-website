@description(' Storage Account name')
param storageAccountName string

@description('resources location')
param location string = resourceGroup().location

@description(' SKU for Storage Account')
param storageSku string = 'Standard_LRS'

@description('CDN profile name')
param cdnProfileName string

@description('SKU of the CDN profile')
param cdnSku string = 'Standard_Microsoft'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    staticWebsite: {
      enabled: true
      indexDocument: 'index.html'
      errorDocument404Path: '404.html'
    }
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2023-01-01' = {
  name: cdnProfileName
  location: location
  sku: {
    name: cdnSku
  }
}

resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2023-01-01' = {
  name: '${cdnProfileName}-endpoint'
  parent: cdnProfile
  location: location
  properties: {
    originHostHeader: '${storageAccountName}.z29.web.core.windows.net'
    origins: [
      {
        name: 'storageOrigin'
        hostName: '${storageAccountName}.z29.web.core.windows.net'
      }
    ]
    isHttpAllowed: true
    isHttpsAllowed: true
  }
}

output websiteUrl string = 'https://${cdnEndpoint.name}.azureedge.net/'
