param apim_name string
param location string = resourceGroup().location

// APIM instance
resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apim_name
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  properties: {
    publisherName: 'John Doe'
    publisherEmail: 'john.doe@nomail.com'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Service Policy
resource apim_policy 'Microsoft.ApiManagement/service/policies@2021-08-01' = {
  parent: apim
  name: 'policy'
  properties: {
    value: service_policy
    format: 'xml'
  }
}

// Service Policy Definition
var service_policy = '''
<policies>
    <inbound>
        <cors allow-credentials="false">
            <allowed-origins>
                <origin>*</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
            </allowed-methods>
        </cors>
    </inbound>
    <backend>
        <forward-request />
    </backend>
    <outbound />
    <on-error />
</policies>'''

// API
resource api 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'dropbox-demo'
  parent: apim
  properties: {
    serviceUrl:'https://api.dropboxapi.com'
    path: 'dropbox-demo'
    displayName:'dropbox-demo'
    protocols:[
      'https'
    ]
  }
}

// Operation
resource api_gettoken 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  name: 'gettoken'
  parent: api
  properties: {
    method: 'GET'
    urlTemplate: '/token'
    displayName: 'gettoken'
  }
}

// Operation Policy
resource api_gettoken_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-08-01' = {
  parent: api_gettoken
  name: 'policy'
  properties: {
    value: operation_token_policy
    format: 'xml'
  }
}

// Operation Token Policy Definition
var operation_token_policy = '''<policies>
<inbound>
    <base />
    <get-authorization-context provider-id="dropbox-demo" authorization-id="auth" context-variable-name="auth-context" ignore-error="false" identity-type="managed" />
    <return-response>
        <set-body>@(((Authorization)context.Variables.GetValueOrDefault(&quot;auth-context&quot;))?.AccessToken)</set-body>
    </return-response>
</inbound>
<backend>
    <base />
</backend>
<outbound>
    <base />
</outbound>
<on-error>
    <base />
</on-error>
</policies>'''
