targetScope = 'subscription'

@description('Name')
param name string 
@description('Resource group location. Default to "westcentralus"')
param location string = 'westcentralus'

var apim_name = '${name}-apim'
var sttapp_name_blazor = '${name}-blazor'
var sttapp_name_react = '${name}-react'

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${name}'
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

module sttapp_blazor './sttapp.bicep' = {
  scope: resourcegroup
  name: 'sttapp_blazor'
  params: {
    sttapp_name: sttapp_name_blazor
    location: 'centralus'
  }
}

module sttapp_react './sttapp.bicep' = {
  scope: resourcegroup
  name: 'sttapp_react'
  params: {
    sttapp_name: sttapp_name_react
    location: 'centralus'
  }
}
