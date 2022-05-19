#!/bin/bash

set -e

urls=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/aaronpowell/token-store-demo/releases/latest | jq '[.assets[] | .browser_download_url]')

blazorzip=$(echo $urls | jq 'select(.name == "blazor.zip") | .url' -r)
reactzip=$(echo $urls | jq 'select(.name == "react.zip") | .url' -r)

resource_group="rg-$RESOURCE_GROUP_NAME"
apim_service_name="apim-$APIM_NAME"

subscription_id=$(az account show | jq '.id' -r)
apim_secret_uri=/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.ApiManagement/service/$apim_service_name/subscriptions/master/listSecrets
api_version=2021-08-01

subscription_key=$(az rest --method post --uri $apim_secret_uri\?api-version=$api_version | jq '.primaryKey' -r)

access_token_uri=https://$apim_service_name.azure-api.net/dropbox-demo/token\?subscription-key=$subscription_key
