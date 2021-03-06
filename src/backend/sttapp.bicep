// create the Static Web Apps name
param sttapp_name string
param location string = 'centralus'


resource sttapp 'Microsoft.Web/staticSites@2021-02-01' = {
  name: '${sttapp_name}-swa'
  location: location
  sku: {
    name: 'Free'
  }
  properties: {
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
  }
}
