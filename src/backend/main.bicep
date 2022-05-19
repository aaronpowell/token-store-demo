
targetScope = 'subscription'

param apim_name string 
param rg_name string 
param location string 

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rg_name
  location: location
}

module apim './apim.bicep' = {
  scope: resourcegroup
  name: 'apimservicedeployment'
  params: {
    apim_name: apim_name
    location: location
  }
}
