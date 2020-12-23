#!/bin/bash

source config.sh

LATEST_VERSION=$( \
        curl -v --silent -L https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 | \
        grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | \
        sed 's#.*/bedrock-server-##' | sed 's/.zip//')

az acr build --registry $ACR_NAME --image bedrock:$LATEST_VERSION --image bedrock:latest .