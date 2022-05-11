# .\authorizations.ps1 -Subscription [subscriptionid] -Resourcegroup [resourcegroup] -ApimServiceName [apimservicename] -ClientId [clientid] -ClientSecret [clientsecret]
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Subscription,

    [Parameter(Mandatory)]
    [string]$Resourcegroup,

    [Parameter(Mandatory)]
    [string]$ApimServiceName,

    [Parameter(Mandatory)]
    [string]$ClientId,

    [Parameter(Mandatory)]
    [string]$ClientSecret
)

# Set variables 
$AuthorizationProvider = 'dropbox-demo' 
$Authorization = 'auth'
$Baseurl = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$Resourcegroup/providers/Microsoft.ApiManagement/service/$apimServiceName/authorizationProviders/$AuthorizationProvider"
$Version = "?api-version=2021-12-01-preview"

$AccessToken = Get-AzAccessToken
$Token = $AccessToken.Token | ConvertTo-SecureString -AsPlainText -Force
$Tenant = $AccessToken.TenantId


# Set json body for authorization provider 
$Body = '
{
    "properties": {
        "identityProvider": "dropbox", 
        "oauth2": {
            "grantTypes": {
                "authorizationCode": {
                    "clientId": "'+$ClientId+'",
                    "clientSecret": "'+$ClientSecret+'",
                    "scopes": "r_liteprofile"
                }
            }
        }
    }
}'

$Params = @{
    Method = "Put"
    Uri = $Baseurl+$Version
    Body = $Body
    ContentType = "application/json"
    Authentication = "Bearer"
    Token = $Token
}

# Create authorization provider
Invoke-RestMethod @Params

# Set json body for authorization 
$Body = '
{
    "properties": {
        "authorizationType": "oauth2",
        "oauth2grantType": "authorizationCode"
    }
}'

$Params = @{
    Method = "Put"
    Uri = $Baseurl+"/authorizations/"+$Authorization+$Version
    Body = $Body
    ContentType = "application/json"
    Authentication = "Bearer"
    Token = $Token
}

# Create access policy, grant access to APIM Manaed Identity
Invoke-RestMethod @Params

# Get objectid for Managed Identity using az CLI 
$ManagedIdentity = Invoke-Expression "az apim show -g $Resourcegroup -n $ApimServiceName --query 'identity.principalId'"

$Body = '{
    "properties": {
        "objectid": '+$ManagedIdentity+',
        "tenantid": "'+$Tenant+'"
    }
}'

$Params = @{
    Method = "Put"
    Uri = $Baseurl+"/authorizations/"+$Authorization+"/accessPolicies/"+$ManagedIdentity+$Version
    Body = $Body
    ContentType = "application/json"
    Authentication = "Bearer"
    Token = $Token
}

Invoke-RestMethod @Params