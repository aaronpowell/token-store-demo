// create the Deployment Script name
param rg_name string
param depscrpt_name string
param apim_name string
param sttapp_name_blazor string
param sttapp_name_react string
param location string = resourceGroup().location 

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'spn-${depscrpt_name}'
  location: location
}

resource role 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(resourceGroup().id, 'contributor')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: uai.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource depscrpt 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'depscrpt-${depscrpt_name}'
  location: location
  dependsOn: [
    role
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uai.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.33.1'
    containerSettings: {
      containerGroupName: 'contgrp-${depscrpt_name}'
    }
    environmentVariables: [
      {
        name: 'RESOURCE_GROUP_NAME'
        value: rg_name
      }
      {
        name: 'APIM_NAME'
        value: apim_name
      }
      {
        name: 'STTAPP_NAME_BLAZOR'
        value: sttapp_name_blazor
      }
      {
        name: 'STTAPP_NAME_REACT'
        value: sttapp_name_react
      }
    ]
    primaryScriptUri: 'https://raw.githubusercontent.com/justinyoo/token-store-demo/main/src/backend/setup-swa.sh?token=GHSAT0AAAAAABOYV4LLIWQJSIOLPSLAIR4YYULHS6Q'
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
  }
}
