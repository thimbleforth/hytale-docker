FROM alpine:3.14
WORKDIR /hytale
COPY ./hytale-downloader-linux-amd64 .
RUN apk update && apk upgrade
