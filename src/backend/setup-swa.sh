#!/bin/bash

set -e

# Update and upgrade
apk update && apk upgrade \
    && apk add -U curl bash ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils \
    && apk add -U bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib \
    && apk add -U libgdiplus --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ \
    && apk add -U libc6-compat gcompat

# Install .NET 6
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin -c 6.0
export PATH=$PATH:/root/.dotnet

# Install nvm
cd ~
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Install node.js
nvm install --lts
nvm use --lts

# Install SWA CLI
corepack enable
yarn global add @azure/static-web-apps-cli

# Get the artifact download URLs
# urls=$(curl \
#     -H "Accept: application/vnd.github.v3+json" \
#     https://api.github.com/repos/aaronpowell/token-store-demo/releases/latest | \
#     jq '[.assets[] | { name: .name, url: .url, download_url: .browser_download_url }]')

urls=$(curl \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: Bearer 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" \
    https://api.github.com/repos/justinyoo/token-store-demo/releases/latest | \
    jq '[.assets[] | { name: .name, url: .url, download_url: .browser_download_url }]')

blazorzip=$(echo $urls | jq '.[] | select(.name == "blazor.zip") | .url' -r)
reactzip=$(echo $urls | jq '.[] | select(.name == "react.zip") | .url' -r)

## Download artifacts
# curl -L -H "Accept: application/octet-stream" $blazorzip -o blazor.zip
# curl -L -H "Accept: application/octet-stream" $reactzip -o react.zip

curl -L -H "Accept: application/octet-stream" -H "Authorization: Bearer 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" $blazorzip -o ~/blazor.zip
curl -L -H "Accept: application/octet-stream" -H "Authorization: Bearer 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" $reactzip -o ~/react.zip

mkdir ~/artifacts
mkdir ~/artifacts/blazor
mkdir ~/artifacts/react

unzip ~/blazor.zip -d ~/artifacts/blazor
unzip ~/react.zip -d ~/artifacts/react

# Get APIM endpoint
subscription_id=$(az account show --query "id" -o tsv)
resource_group="rg-$RESOURCE_GROUP_NAME"
apim_service="apim-$APIM_NAME"

apim_secret_uri=/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.ApiManagement/service/$apim_service/subscriptions/master/listSecrets
api_version=2021-08-01
gateway_url=$(az apim show -g $resource_group -n $apim_service --query "gatewayUrl" -o tsv)
subscription_key=$(az rest --method post --uri $apim_secret_uri\?api-version=$api_version | jq '.primaryKey' -r)
apim_endpoint=$gateway_url/dropbox-demo/token\?subscription-key=$subscription_key

# Update environment variables
cd ~/artifacts/blazor/wwwroot
echo "{ \"APIM_Endpoint\": \"$apim_endpoint\" }" > appsettings.json
cd ~/artifacts/blazor
dotnet publish -c Release
cd ~

# Build React app
cd ~/artifacts/react
echo "VITE_APIM_ENDPOINT=$apim_endpoint" > .env
# npm install
npm run build
cd ~

# Get SWA deployment key
resource_group="rg-$RESOURCE_GROUP_NAME"
sttapp_blazor="sttapp-$STTAPP_NAME_BLAZOR"
sttapp_react="sttapp-$STTAPP_NAME_REACT"

sttapp_blazor_token=$(az staticwebapp secrets list -g $resource_group -n $sttapp_blazor --query "properties.apiKey" -o tsv)
sttapp_react_token=$(az staticwebapp secrets list -g $resource_group -n $sttapp_react --query "properties.apiKey" -o tsv)

# Deploy SWA apps
swa deploy -R $resource_group -n $sttapp_blazor -a ~/artifacts/blazor/bin/Release/net6.0/publish/wwwroot -d $sttapp_blazor_token --env default
swa deploy -R $resource_group -n $sttapp_react -a ~/artifacts/react/dist -d $sttapp_react_token --env default
