# Hytale Server Docker 🧱🐉

Lightweight Docker image for preparing a Hytale server using a downloader binary.

This really is for *running* the server after you've downloaded it and authenticated it with the Hytale main server. This repo does not automatically pull down the server, authenticate for you, AND then create the Docker image. It only does that last part.

## Overview 🔧

This repository provides a minimal Dockerfile that copies the `hytale-downloader-linux-amd64` binary from the Hytale website into an Alpine base image, and prepares a working directory at `/hytale`. The downloader is not included in the repository and is intentionally ignored (`.gitignore`).

> Note: This project does not ship the downloader binary. Place your own `hytale-downloader-linux-amd64` in the repository root, and authenticate and download the game before building the image. You can get it from [the Hytale Accounts page](https://accounts.hytale.com/download).
> Note again: the Dockerfile will handle extracting the .zip file, installing the JRE, and running the server for you. All you have to do is download it first, because right now it keeps breaking but downloading it first is a one-shot thing and I'm lazy.

### IMPORTANT: Running the Hytale Server

Start the server by copying the included `server-start.sh` file into the chosen volume storage.

Be sure to `chmod 750` the script file.

Then, by connecting to the Docker container, running `ash`, in context of the `hytale` user, run the script.

It'll take you through the rest.

Per the Hytale website's [Hytale Server Manual page](https://support.hytale.com/hc/en-us/articles/45326769420827-Hytale-Server-Manual#server-setup), you should do the following things AFTER downloading and extracting the server.

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
- `docker-compose.yaml` - builds the Compose stack, defines the persistent volume, port, and hardens the image.
- `LICENSE` - Apache 2.0, cuz why not.
- `.gitignore` - ignores the downloader and `QUICKSTART.md` if present.
- `server-start.sh` - runs Java and starts the server with sane defaults.

## Prerequisites

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

After the Compose stack is run with `docker compose up`, copy the `server-start.sh` file into the persistent volume storage.

Notes:

- Ensure `SERVERFILESPATH` is an absolute path on the host to avoid unexpected relative-path behavior.
- The exact downloader flags may differ depending on the binary you have; check the binary's help output (e.g. `./hytale-downloader-linux-amd64 --help`).

## Contributing & PRs ✅

Contributions are welcome. Open an issue or PR.

## License 📜

This repository is licensed under the Apache License 2.0. See `LICENSE` for details.
