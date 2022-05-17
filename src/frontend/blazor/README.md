# Token Store: Blazor Lead Capture #

## Prerequisites ##

* [.NET SDK 6.0.300 or later](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)


## Getting Started ##

* Create APIM Token Store
  * https://github.com/aaronpowell/token-store-demo/tree/main/src/backend
* Add GitHub Secrets
  * `APIM_ENDPOINT`: The endpoint generated from APIM above is stored here. This value will be added to `appsettings.json` before deployment.
* Create Azure Static Apps through Azure Portal, with Blazor configurations
  * Follow [this document](https://docs.microsoft.com/azure/static-web-apps/deploy-blazor#create-a-static-web-app) for publishing.
