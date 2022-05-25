
1. Create API Management instance and API configuration     

    az deployment sub create -n apimdeployment -l westcentralus -f main.bicep -p name=[NAME] location=[AZURE_REGION]

    [APIM_SERVICENAME]=[NAME]-apim
    [RESOURCE_GROUP]=rg-[NAME]

3. Create an application at https://www.dropbox.com/developers using  https://authorization-manager.consent.azure-apim.net/redirect/apim/[APIM_SERVICENAME] as the redirect url. 

3. Create Authorizations configuration in API Management
    .\authorizations.ps1 -Subscription [SUBSCRIPTION_ID] -Resourcegroup [RESOURCE_GROUP] -ApimServiceName [APIM_SERVICENAME] -ClientId [DROPBOX_CLIENTID] -ClientSecret [DROPBOX_CLIENT_SECRET] 

4. Perform the consent from the Azure portal --> API Management --> Authorizations(preview) --> dropbox-demo --> Authorization --> right click on context menu to the right, choose Login, do the consent.  

5. Test API
    Get API key from API Management and test  
    GET https://[APIM_SERVICENAME].azure-api.net/dropbox-demo/token?subscription-key=[API-KEY]

