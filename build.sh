#!/bin/bash

RESOURCE_GROUP=mc
ACR_NAME=dchmc

docker build -t bedrock:latest .

az acr login --name $ACR_NAME
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)
docker tag bedrock $ACR_LOGIN_SERVER/bedrock:latest
docker push $ACR_LOGIN_SERVER/bedrock