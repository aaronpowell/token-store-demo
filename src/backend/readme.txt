Requirements
- Azure CLI
- RBAC Contributor role in API Management
- Logged into azure (az login)


1. Use an existing API Management service

2. Create API in API Management  
    az deployment group create -g [RESOURCE_GROUP] -f main.bicep -p apim_name=[APIM_SERVICENAME]

    az deployment sub create --name apimdeployment --location westcentralus --template-file main.bicep

    az deployment sub create -n apimdeployment -l westcentralus -f main.bicep -p apim_name=[APIM_SERVICENAME] rg_name=[RESOURCEGROUP_NAME] location=[AZURE_REGION]


3. Create an application at https://www.dropbox.com/developers using  https://authorization-manager.consent.azure-apim.net/redirect/apim/[APIM_SERVICENAME] as redirecturl 

3. Create Authorizations configuration in API Management
    .\authorizations.ps1 -Subscription [SUBSCRIPTION_ID] -Resourcegroup [RESOURCE_GROUP] -ApimServiceName [APIM_SERVICENAME] -ClientId [DROPBOX_CLIENTID] -ClientSecret [DROPBOX_CLIENT_SECRET] 

4. Perform the consent from the Azure portal --> API Management --> Authorizations(preview) --> dropbox-demo --> Authorization --> right click on context menu to the right, choose Login, do the consent.  

5. Test API
    Get API key from API Management and test  
    GET https://[APIM_SERVICENAME].azure-api.net/dropbox-demo/token?subscription-key=[API-KEY]

