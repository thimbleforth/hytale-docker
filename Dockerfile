FROM alpine:3.14

WORKDIR /hytale

# Create a dedicated non-root user and group for running the server
RUN addgroup -S hytale \
    && adduser -S -G hytale -h /home/hytale -s /sbin/nologin hytale \
    && mkdir -p /home/hytale \
    && chown -R hytale:hytale /home/hytale

# Copy server binary and harden permissions / capabilities
COPY ./hytale-downloader-linux-amd64 ./hytale-server
COPY ./hytale.zip /hytale/hytale.zip
COPY ./hytale-downloader-credentials.json /hytale/.hytale-downloader-credentials.json
RUN apk add --no-cache --virtual .cap-deps libcap \
    && chmod 750 /hytale/hytale-server && chmod 750 /hytale/hytale.zip && chmod 600 /hytale/.hytale-downloader-credentials.json \
    # make group the hytale group so the hytale user can execute
    && chown root:hytale /hytale/hytale-server && chown root:hytale /hytale/hytale.zip && chown root:hytale /hytale/.hytale-downloader-credentials.json \
    # remove any filesystem capabilities that might be present
    && setcap -r /hytale/hytale-server || true \
    # ensure no suid bits on the binary, zip, or credentials file
    && chmod u-s /hytale/hytale-server && chmod u-s /hytale/hytale.zip && chmod u-s /hytale/.hytale-downloader-credentials.json \
    && apk del .cap-deps \
    && apk update && apk upgrade && rm -rf /var/cache/apk/*

# Run the container as the non-root user for better security
USER hytale
ENV HOME=/home/hytale

# Run the server as the non-root user.
CMD ["/hytale/hytale-server"]
