#!/bin/bash

set -e

# Update and upgrade
apk update && apk upgrade \
    && apk add -U curl bash ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils \
    && apk add -U libc6-compat gcompat

# Install nvm
cd ~
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

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

curl -L -H "Accept: application/octet-stream" -H "Authorization: Bearer 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" $blazorzip -o blazor.zip
curl -L -H "Accept: application/octet-stream" -H "Authorization: Bearer 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" $reactzip -o react.zip

mkdir artifacts
mkdir artifacts/blazor
mkdir artifacts/react

unzip blazor.zip -d artifacts/blazor
unzip react.zip -d artifacts/react

# Get SWA deployment key
resource_group="rg-$RESOURCE_GROUP_NAME"
sttapp_blazor="sttapp-$STTAPP_NAME_BLAZOR"
sttapp_react="sttapp-$STTAPP_NAME_REACT"

sttapp_blazor_token=$(az staticwebapp secrets list -g $resource_group -n $sttapp_blazor --query "properties.apiKey" -o tsv)
sttapp_react_token=$(az staticwebapp secrets list -g $resource_group -n $sttapp_react --query "properties.apiKey" -o tsv)

# Deploy SWA apps
swa deploy -R $resource_group -n $sttapp_blazor -a artifacts/blazor -d $sttapp_blazor_token --env default
swa deploy -R $resource_group -n $sttapp_react -a artifacts/react -d $sttapp_react_token --env default