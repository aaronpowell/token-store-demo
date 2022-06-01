## Creating the resources using Bicep

1. Create API Management instance and API configuration

    az deployment sub create -n apimdeployment -l westcentralus -f main.bicep -p name=[NAME] location=[AZURE_REGION]

    [APIM_SERVICENAME]=[NAME]-apim
    [RESOURCE_GROUP]=rg-[NAME]

2. Create an application at https://www.dropbox.com/developers using https://authorization-manager.consent.azure-apim.net/redirect/apim/[APIM_SERVICENAME] as the redirect url.

3. Create Authorizations configuration in API Management
   .\authorizations.ps1 -Subscription [SUBSCRIPTION_ID] -Resourcegroup [RESOURCE_GROUP] -ApimServiceName [APIM_SERVICENAME] -ClientId [DROPBOX_CLIENTID] -ClientSecret [DROPBOX_CLIENT_SECRET]

4. Perform the consent from the Azure portal --> API Management --> Authorizations(preview) --> dropbox-demo --> Authorization --> right click on context menu to the right, choose Login, do the consent.

5. Test API
   Get API key from API Management and test  
   GET https://[APIM_SERVICENAME].azure-api.net/dropbox-demo/token?subscription-key=[API-KEY]

## How it works

There's a bunch of resources that we setup with the [Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/overview?tabs=bicep&WT.mc_id=javascript-57408-aapowell) deployment and scripts, so let's take a look at how it all worked.

_Note: Please be aware this is preview so there may be some changes before the final release._

Let's start with the Bicep template for provisioning the APIM resource:

```bicep
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
    publisherName: 'Aaron Powell'
    publisherEmail: 'my@email.com'
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

```

Wow, that's a lot of stuff, so let's break it down a bit.

```bicep
param apim_name string

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apim_name
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  properties: {
    publisherName: 'Aaron Powell'
    publisherEmail: 'my@email.com'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
```

Here we're defining the API Management resource and saying that a parameter to the Bicep template, `apim_name`, will be provided for its name. We've got the SKU hard-coded, as well as the publisher information, you could configure that as additional `param` values, or set them to what you'd prefer.

```bicep
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
```

With the APIM resource created we can go ahead and create a _service policy_ for it which defines how you can communicate with APIM from the client apps. The XML `service_policy` is allowing CORS via all endpoints (but you might want to restrict that to trusted domains in production) and allowing both `GET` and `POST` requests.

Next, we're going to add the Authorizations service to API Management that will talk to Dropbox:

```bicep
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
```

The `path` property of the service is important, this is what we'll be using in the policy we're going to create shortly for getting the access token, and also in the REST API calls to configure the service.

When it comes to getting the access token back from the token store, we can do it several ways, but the simplest is to create an API in APIM that returns it, and we can do that with Bicep:

```bicep
resource api_gettoken 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  name: 'gettoken'
  parent: api
  properties: {
    method: 'GET'
    urlTemplate: '/token'
    displayName: 'gettoken'
  }
}
```

Adding this API will mean that our APIM endpoint is going to have an API we can call at `/token` to get back the access token, and we haven't had to write any code for that, APIM handles it all using a policy:

```bicep
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
```

This last piece of Bicep is defining a [policy in APIM](https://docs.microsoft.com/azure/api-management/api-management-policies?WT.mc_id=javascript-57408-aapowell), and while it looks like a large chunk of XML there's two important pieces to focus on, first in the `get-authorization-context` node we set the `provider` to value of the `path` property from our service creation (in this case it's `dropbox-demo`), so we know which authorization context is going to be used to provide the token.

The other part of the policy is the `return-response` in which we use `set-body` to run a little bit of code, `@(((Authorization)context.Variables.GetValueOrDefault(&quot;auth-context&quot;))?.AccessToken)`, which is C# code that unpacks the access token the context and that's what we'll get in the response.

### Configuring the authorization context

So, we've told APIM that we're going to use Dropbox as an authorization context and configured a service for it, the last thing we have to do is provide it with credentials to talk to Dropbox and get the access token back.

Follow the [Dropbox docs to setup an app](https://dropbox.com/developers/apps) and copy the `client id` and `client secret`, as we'll need to provide them for APIM.

_Note: Just a reminder, we're going to use the Azure REST API to do this as the preview currently doesn't support this via Bicep, but this will change in future releases._

We'll use the [Azure CLI](https://docs.microsoft.com/cli/azure/?WT.mc_id=javascript-57408-aapowell) and run it via [Cloud Shell](https://shell.azure.com?WT.mc_id=javascript-57408-aapowell) to speed things up.

You'll need a few bit of information from your APIM resource, the **subscription ID**, **resource group name**, **APIM resource name** and **authorization service name**. You'll have the first two from deploying the Bicep template, the APIM resource name was the parameter we provided and the service name we set as `dropbox-demo`, let's set them as environment variables in the shell (I'm using Bash, but you could use PowerShell if preferred). We can also setup environment variables for the Dropbox client id/client secret while we're at it.

```bash
SUBSCRIPTION_ID=<...>
RESOURCE_GROUP=<...>
APIM_NAME=<...>
SERVICE_NAME=dropbox-demo
CLIENT_ID=<...>
CLIENT_SECRET=<...>
VERSION="?api-version=2021-12-01-preview"
```

We'll next construct the URI that we need to make the REST call against:

```bash
BASE_URI="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_NAME/authorizationProviders/$SERVICE_NAME"
```

We need to `PUT` some data to that endpoint to provide the Dropbox client id/client secret to Azure, so let's build the request body:

```bash
BODY="
{
    \"properties\": {
        \"identityProvider\": \"dropbox\",
        \"oauth2\": {
            \"grantTypes\": {
                \"authorizationCode\": {
                    \"clientId\": \"$CLIENT_ID\",
                    \"clientSecret\": \"$CLIENT_SECRET\",
                    \"scopes\": \"files.metadata.write files.content.write files.content.read\"
                }
            }
        }
    }
}"
```

Now we can send this to Azure:

```bash
az rest --method put --body $BODY --url "$BASE_URI/$VERSION"
```

This will configure the Dropbox Authorization for APIM using the credentials we provided it and the scopes that are set (make sure you set the right scopes for the needs of your application, these are the basic scopes to upload new files to Dropbox).

Next, we need to configure the authorization flow that the provider will use. Since this is operating in a "headless" manner, we'll be using the _authorizationCode_ OAuth2 flow, and we'll need to create a new JSON payload to set that:

```bash
BODY="
{
    \"properties\": {
        \"authorizationType\": \"oauth2\",
        \"oauth2grantType\": \"authorizationCode\"
    }
}"
```

And we can send that one to Azure (note - this is going to a new REST endpoint so the URL expands a bit):

```bash
az rest --method put --body $BODY --url "$BASE_URI/authorizations/auth$VERSION"
```

Lastly, we'll create a managed identity for APIM to operate as, allowing it to refresh the OAuth2 tokens as required. For that we'll need to get two bits of information, the identity and the tenant:

```bash
MANAGED_IDENTITY=$(az apim show -g $RESOURCE_GROUP -n $APIM_NAME --query 'identity.principalId')
TENANT_ID=$(az account get-access-token --query tenant --output tsv)
```

Then it's time to create the final JSON payload:

```bash
BODY="
{
    \"properties\": {
        \"objectid\": \"$MANAGED_IDENTITY\",
        \"tenantid\": \"$TENANT_ID\"
    }
}"
```

And send it to Azure:

```bash
az rest --method put --body $BODY --url "$BASE_URI/authorizations/auth/accessPolicies/$MANAGED_IDENTITY$VERSION"
```
