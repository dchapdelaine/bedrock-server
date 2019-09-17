#!/bin/bash

source config.sh

# Get the key
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)

ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)

# Create the container instance
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $ACI_NAME \
    --image $ACR_LOGIN_SERVER/bedrock:latest \
    --registry-username $(az keyvault secret show --vault-name $AKV_NAME -n $ACR_NAME-pull-usr --query value -o tsv) \
    --registry-password $(az keyvault secret show --vault-name $AKV_NAME -n $ACR_NAME-pull-pwd --query value -o tsv) \
    --dns-name-label $ACI_NAME \
    --ports 19132 \
    --protocol udp \
    --assign-identity $SERVICE_PRINCIPAL_ID \
    --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $SHARE_NAME \
    --azure-file-volume-mount-path /bedrock-server/worlds/ \
    --cpu 2 \
    --memory 2