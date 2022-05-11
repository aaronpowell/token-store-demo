
param apim_name string

resource apim 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apim_name
}

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

resource api_gettoken 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  name: 'gettoken'
  parent: api
  properties: {
    method: 'GET'
    urlTemplate: '/token'
    displayName: 'gettoken'
  }
}

resource api_gettoken_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-08-01' = {
  parent: api_gettoken
  name: 'policy'
  properties: {
    value: operation_token_policy
    format: 'xml'
  }
}

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
