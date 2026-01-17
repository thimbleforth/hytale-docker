# Hytale Server Docker 🧱🐉

Lightweight Docker image for preparing a Hytale server using a downloader binary.

This really is for *running* the server after you've downloaded it and authenticated it with the Hytale main server. This repo does not automatically pull down the server, authenticate for you, AND then create the Docker image. It only does that last part.

## Overview 🔧

This repository provides a minimal Dockerfile that copies the `hytale-downloader-linux-amd64` binary from the Hytale website into an Alpine base image, and prepares a working directory at `/hytale`. The downloader is not included in the repository and is intentionally ignored (`.gitignore`).

> Note: This project does not ship the downloader binary. Place your own `hytale-downloader-linux-amd64` in the repository root, and authenticate and download the game before building the image. You can get it from [the Hytale Accounts page](https://accounts.hytale.com/download).
> Note again: the Dockerfile will handle extracting the .zip file, installing the JRE, and running the server for you. All you have to do is download it first, because right now it keeps breaking but downloading it first is a one-shot thing and I'm lazy.

## Do this before creating the Docker image

Per the Hytale website's [Hytale Server Manual page](https://support.hytale.com/hc/en-us/articles/45326769420827-Hytale-Server-Manual#server-setup), you should do the following things AFTER downloading and extracting the server.

Doing this **before** you copy it all into the Docker container using the Compose and Dockerfile combo means the server's fully cooked and ready to run, without any additional ports, tweaks, dependencies, or weird one-off scripts.

### Running a Hytale Server

Start the server with:
`java -jar HytaleServer.jar --assets PathToAssets.zip`

### Authentication

After first launch, authenticate your server.
`/auth login device`

```plaintext
===================================================================
DEVICE AUTHORIZATION
===================================================================
Visit: https://accounts.hytale.com/device
Enter code: ABCD-1234
Or visit: https://accounts.hytale.com/device?user_code=ABCD-1234
===================================================================
Waiting for authorization (expires in 900 seconds)...
[User completes authorization in browser]
Authentication successful! Mode: OAUTH_DEVICE
```

Once authenticated, your server can accept player connections.

## Contents 📁

- `Dockerfile` - builds an Alpine image and sets `/hytale` as the working dir.
- `LICENSE` - Apache 2.0, cuz why not.
- `.gitignore` - ignores the downloader and `QUICKSTART.md` if present.

## Quick start 🚀

1. Obtain the `hytale-downloader-linux-amd64` binary and place it in the repository root.

2. Build the Docker image:

```sh
docker build -t hytale-server .
```

### Using Docker Compose (recommended for iterative tweaks)

This repository includes a `docker-compose.yaml` that builds the image and runs the container as a non-root user, and mounts a host path (from `SERVERFILESPATH`) into `/hytale/data`.

Example `.env` values you can set in your shell or a `.env` file:

```env
# Absolute path on host where server files will be stored
SERVERFILESPATH=/home/youruser/hytale-data
```

Start the container (build if needed):

```sh
docker compose up --build
```

Notes:

- Ensure `SERVERFILESPATH` is an absolute path on the host to avoid unexpected relative-path behavior.
- `PUID`/`PGID` let the container process run as that numeric user and preserve file permissions on host-mounted volumes.
- The `entrypoint` is currently `bash` for interactive tweaking; change it later to run the downloader directly if desired.

- The exact downloader flags may differ depending on the binary you have; check the binary's help output (e.g. `./hytale-downloader-linux-amd64 --help`).

## Contributing & PRs ✅

Contributions are welcome. Open an issue or PR.

## License 📜

This repository is licensed under the Apache License 2.0. See `LICENSE` for details.
