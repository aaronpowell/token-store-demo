
targetScope = 'subscription'

param rg_name string 
param apim_name string
param sttapp_name_blazor string
param sttapp_name_react string
param depscrpt_name string
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
