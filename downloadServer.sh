#!/bin/bash

if [ "$VERSION" = "latest" ] ; then
    LATEST_VERSION=$( \
        curl -v -L --silent  https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 | \
        grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | \
        sed 's#.*/bedrock-server-##' | sed 's/.zip//')
    export VERSION=$LATEST_VERSION
    echo "Setting VERSION to $LATEST_VERSION"
else echo "Using VERSION of $VERSION"
fi
curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${VERSION}.zip --output bedrock-server.zip
unzip bedrock-server.zip -d bedrock-server
rm bedrock-server.zip