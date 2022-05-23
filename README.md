# Token Store: Azure API Management Authorizations #

## Prerequisites ##

* For Blazor app: [.NET SDK 6.0.300 or later](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)
* For React app: [node.js v14 or later](https://nodejs.org/en/download/)


## Getting Started ##

### Autopilot ###

click the button below to create and deploy both Blazor WASM app and React app in one go.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/?Microsoft_Azure_ApiManagement=tuanguye2&feature.tokenstores=true#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjustinyoo%2Ftoken-store-demo%2Fmain%2Fsrc%2Fbackend%2Fmain.json%3Ftoken%3DGHSAT0AAAAAABOYV4LKPYAFWUODHEF6PLQWYULHRBQ)


### Step-by-Step Instruction ###

* Create APIM Token Store
  * https://github.com/aaronpowell/token-store-demo/tree/main/src/backend
* Add GitHub Secrets
  * `APIM_ENDPOINT`: The endpoint generated from APIM above is stored here. This value will be added to `appsettings.json` before deployment.
* Create Azure Static Apps through Azure Portal, with Blazor configurations
  * Follow [this document](https://docs.microsoft.com/azure/static-web-apps/deploy-blazor#create-a-static-web-app) for publishing.
