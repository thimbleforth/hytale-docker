# Hytale Server Docker 🧱🐉

Lightweight Docker image for preparing a Hytale server using a downloader binary.

## Overview 🔧

This repository provides a minimal Dockerfile that copies the `hytale-downloader-linux-amd64` binary from the Hytale website into an Alpine base image, and prepares a working directory at `/hytale`. The downloader is not included in the repository and is intentionally ignored (`.gitignore`).

> Note: This project does not ship the downloader binary. Place your own `hytale-downloader-linux-amd64` in the repository root, and authenticate and download the game before building the image. You can get it from [the Hytale Accounts page](https://accounts.hytale.com/download).

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

This repository includes a `docker-compose.yaml` that builds the image and runs the container as a non-root UID/GID, and mounts a host path (from `SERVERFILESPATH`) into `/hytale/data`.

Example `.env` values you can set in your shell or a `.env` file:

```env
# Absolute path on host where server files will be stored
SERVERFILESPATH=/home/youruser/hytale-data
# Map container UID/GID to a non-root host user (defaults to 1000)
PUID=1000
PGID=1000
```

Start the container (build if needed):

```sh
docker compose up --build
```

Run a one-off interactive container (useful for running the downloader):

```sh
docker compose run --rm hytale bash -c "./hytale-downloader-linux-amd64 --output /hytale/data"
```

Or attach to a running container:

```sh
docker compose exec hytale bash
```

Notes:

- Ensure `SERVERFILESPATH` is an absolute path on the host to avoid unexpected relative-path behavior.
- `PUID`/`PGID` let the container process run as that numeric user and preserve file permissions on host-mounted volumes.
- The `entrypoint` is currently `bash` for interactive tweaking; change it later to run the downloader directly if desired.

- The exact downloader flags may differ depending on the binary you have; check the binary's help output (e.g. `./hytale-downloader-linux-amd64 --help`).

## Suggested usage notes 💡

- Persist downloaded server assets using a host volume (recommended).

## Contributing & PRs ✅

Contributions are welcome. Open an issue or PR.

## License 📜

This repository is licensed under the Apache License 2.0. See `LICENSE` for details.
