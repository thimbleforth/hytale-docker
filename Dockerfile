FROM alpine:3.14

WORKDIR /hytale

# Create a dedicated non-root user and group for running the server
RUN addgroup -S hytale \
    && adduser -S -G hytale -h /home/hytale -s /sbin/nologin hytale \
    && mkdir -p /home/hytale \
    && chown -R hytale:hytale /home/hytale

# Copy server binary and harden permissions / capabilities
COPY ./hytale-downloader-linux-amd64 ./hytale-server
RUN apk add --no-cache --virtual .cap-deps libcap \
    && chmod 750 /hytale/hytale-server \
    # make group the hytale group so the hytale user can execute
    && chown root:hytale /hytale/hytale-server \
    # remove any filesystem capabilities that might be present
    && setcap -r /hytale/hytale-server || true \
    # ensure no suid bits on the binary
    && chmod u-s /hytale/hytale-server \
    && apk del .cap-deps \
    && apk update && apk upgrade && rm -rf /var/cache/apk/*

# Run the container as the non-root user for better security
USER hytale
ENV HOME=/home/hytale

# Run the server as the non-root user.
CMD ["/hytale/hytale-server"]
