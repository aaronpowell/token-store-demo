targetScope = 'subscription'

@description('Resource group name')
param rg_name string 
@description('Resource group location. Default to "westcentralus"')
param location string = 'westcentralus'

var apim_name = rg_name
var sttapp_name_blazor = '${rg_name}-blazor'
var sttapp_name_react = '${rg_name}-react'
var depscrpt_name = rg_name

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${rg_name}'
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

module depscrpt './depscrpt.bicep' = {
  scope: resourcegroup
  name: 'deploymentscript'
  dependsOn: [
    apim
    sttapp_blazor
    sttapp_react
    ]
  params: {
    rg_name: rg_name
    depscrpt_name: depscrpt_name
    apim_name: apim_name
    sttapp_name_blazor: sttapp_name_blazor
    sttapp_name_react: sttapp_name_react
    location: location
  }
}
