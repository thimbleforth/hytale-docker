FROM alpine:edge

WORKDIR /hytale

# Create a dedicated non-root user and group for running the server
RUN addgroup -S hytale \
    && adduser -S -G hytale -h /home/hytale -s /sbin/nologin hytale \
    && mkdir -p /home/hytale \
    && chown -R hytale:hytale /home/hytale

# Copy server binary and harden permissions / capabilities
COPY hytale/ /hytale/
COPY server-start.sh /hytale/server-start.sh

# Install libcap as a temporary virtual package (so we can remove it later)
# Install OpenJDK *separately* so it remains available in the final image
RUN apk add --no-cache --virtual .cap-deps libcap \
    && apk add --no-cache openjdk25-jre-headless libmsquic libgcc libc6-compat byobu \
    && chmod 750 /hytale/Server/HytaleServer.jar && chmod 750 /hytale/server-start.sh \
    # make group the hytale group so the hytale user can execute
    && chown root:hytale /hytale/* && chown root:hytale /hytale/server-start.sh \
    # remove any filesystem capabilities that might be present
    && setcap -r /hytale/Server/HytaleServer.jar || true \
    # ensure no suid bits on the Jarfile
    && chmod u-s /hytale/Server/HytaleServer.jar \
    && apk del .cap-deps \
    && rm -rf /var/cache/apk/*

# Run the container as the non-root user for better security
USER hytale
ENV HOME=/home/hytale

# Run the server as the non-root user.  
# Pass JVM flags to allow native access
CMD ["byobu"]