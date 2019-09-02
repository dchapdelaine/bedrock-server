#!/bin/bash

RESOURCE_GROUP=mc
STORAGE_ACCOUNT_NAME=dchmc
ACR_NAME=dchmc
LOCATION=eastus2
SHARE_NAME=mcdata

# Create the storage account with the parameters
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT_NAME \
    --location $LOCATION \
    --sku Standard_LRS

# Create the file share
az storage share create --name $SHARE_NAME --account-name $STORAGE_ACCOUNT_NAME

# Get the key
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)

az identity create --resource-group $RESOURCE_GROUP --name $ACR_NAME
# Get service principal ID of the user-assigned identity
SERVICE_PRINCIPAL_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query principalId --output tsv)

az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --location $LOCATION \
    --sku basic
   
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role acrpull
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)

# Create the container instance
az container create \
    --resource-group $RESOURCE_GROUP \
    --name mcserver \
    --image $ACR_LOGIN_SERVER/bedrock:latest \
    --dns-name-label dchmc \
    --ports 19132 \
    --protocol udp \
    --assign-identity $SERVICE_PRINCIPAL_ID \
    --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $SHARE_NAME \
    --azure-file-volume-mount-path /bedrock-server/worlds/ \
    --cpu 4 \
    --memory 4