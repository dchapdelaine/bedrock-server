#!/bin/bash

ACR_NAME=dchmc

az acr build --registry $ACR_NAME --image bedrock:latest .