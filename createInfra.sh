#!/bin/bash

source config.sh

# Create the storage account with the parameters
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT_NAME \
    --location $LOCATION \
    --sku Standard_LRS

# Create the file share
az storage share create --name $SHARE_NAME --account-name $STORAGE_ACCOUNT_NAME

az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --location $LOCATION \
    --sku basic

# Create SP and assign role
SP_PASSWORD=$(az ad sp create-for-rbac \
    --name $SP_NAME \
    --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
    --role acrpull \
    --query password \
    --output tsv)

# Get the AppId of the SP
SP_CLIENT_ID=$(az ad sp show --id $SP_NAME --query appId --output tsv)

az keyvault create \
    --name $AKV_NAME \
    --resource-group $RESOURCE_GROUP

# Create service principal, store its password in AKV (the registry *password*)
az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-pull-pwd \
    --value $SP_PASSWORD

# Store service principal ID in AKV (the registry *username*)
az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-pull-usr \
    --value $SP_CLIENT_ID
