FROM ubuntu:18.04
ENV VERSION="latest"

# Install dependencies, download and extract the bedrock server

RUN apt-get update && \
    apt-get install -y unzip curl libcurl4 libssl1.0.0
    
COPY downloadServer.sh .

RUN ./downloadServer.sh

# Create a separate folder for configurations move the original files there and create links for the files
RUN mkdir /bedrock-server/worlds && \
    mv /bedrock-server/server.properties /bedrock-server/worlds && \
    mv /bedrock-server/permissions.json /bedrock-server/worlds && \
    mv /bedrock-server/whitelist.json /bedrock-server/worlds && \
    ln -s /bedrock-server/worlds/server.properties /bedrock-server/server.properties && \
    ln -s /bedrock-server/worlds/permissions.json /bedrock-server/permissions.json && \
    ln -s /bedrock-server/worlds/whitelist.json /bedrock-server/whitelist.json

EXPOSE 19132/udp

VOLUME /bedrock-server/worlds

WORKDIR /bedrock-server
ENV LD_LIBRARY_PATH=.
CMD ./bedrock_server
