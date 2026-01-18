# Hytale Server Docker 🧱🐉

Lightweight Docker image and Compose stack for running a Hytale server.

This repository *does not* download or authenticate the Hytale server for you. It provides a minimal, hardened image and a recommended Compose configuration to run the server once you've obtained the server files.

---

## Overview 🔧

- **Base image:** Alpine (edge)
- **Runtime user:** non-root `hytale` (created in the image)
- **Where files live:** `/hytale` inside the container
- **JRE:** OpenJDK package is installed in the image (currently `openjdk25-jre-headless`)
- **Entrypoint:** `ash /hytale/server-start.sh` (runs as the `hytale` user)

The Dockerfile copies a local `hytale/` directory (if present) and `server-start.sh` into the image. The repository intentionally ignores the `hytale/` directory by default so you can keep server files out of source control; you can either include extracted server files when building the image or mount them from a host directory at runtime.

---

## Two supported workflows 🔁

1. **Include server files in the image (local build)**
   - Place the extracted server files (the `Server/` directory, `HytaleServer.aot`, `Assets.zip`, etc.) into a local `hytale/` directory next to the `Dockerfile` and build the image:

   ```sh
   docker build -t hytale-server .
   ```

   - This bakes the server files into the image (useful for immutable, single-file images).

2. **Use Docker Compose with a host volume (recommended)**
   - Set `SERVERFILESPATH` to an absolute host path (e.g. `/home/you/hytale-data`) and run:

   ```sh
   # example: create host folder and give it the right permissions
   mkdir -p /home/you/hytale-data
   chmod 750 /home/you/hytale-data

   # start the stack
   docker compose up --build
   ```

   - The Compose stack mounts the host path as a bind-mounted volume at `/hytale` (see `docker-compose.yaml`). Note: when using the volume, copy `server-start.sh` into the host directory (it will hide the image's `/hytale` contents when mounted):

   ```sh
   cp server-start.sh /home/you/hytale-data/
   chmod 750 /home/you/hytale-data/server-start.sh
   ```

   - The service runs with a **read-only root filesystem**, `tmpfs` for `/tmp`, dropped capabilities, and `no-new-privileges` for improved security.

---

## Runtime details & tuning 🔧

- Default server start command (in `server-start.sh`):

```sh
java -Xms2G -Xmx4G -XX:AOTCache=/hytale/Server/HytaleServer.aot --enable-native-access=ALL-UNNAMED -jar /hytale/Server/HytaleServer.jar --assets /hytale/Assets.zip
```

- ***It is strongly recommended*** you run `server-start.sh` inside a `byobu` window. That way, you can come back to that session after disconnecting from the Docker instance. Yes it's dirty, yes it's not proper session management, but nobody's paying me to do this either and I'm not hooking up something fancier. :)
- Edit `server-start.sh` to adjust Java memory (`-Xms` / `-Xmx`) or other JVM flags as needed.
- UDP port `5520` is exposed by default for game traffic (mapped in `docker-compose.yaml` as `5520:5520/udp`).

---

## Authentication (after first run) 🔐

On first launch the server requires device authorization. Run this from the server console:

```text
/auth login device
```

You will see a device code and a URL to visit. Enter the code in your browser to authorize the server (the code typically expires in 900 seconds).

---

## Files in this repo 📁

- `Dockerfile` — builds the image (creates non-root user, installs JRE, copies `hytale/` and `server-start.sh`).
- `docker-compose.yaml` — recommended stack with persistent bind mount and security hardening.
- `server-start.sh` — default JVM invocation (adjustable).
- `.gitignore` — excludes `hytale/` and related artifacts to avoid committing server assets.
- `LICENSE` — Apache License 2.0

---

## Notes & troubleshooting 💡

- If you mount a host directory at `/hytale`, it hides whatever the image had at that path — remember to copy `server-start.sh` into the host folder if you want to use the image's startup logic.
- Ensure `SERVERFILESPATH` is an **absolute path** to avoid bind-mount surprises.
- If the downloader binary (`hytale-downloader-linux-amd64`) is used to obtain server files, run it *outside* this repository and place the extracted files into your host folder or the local `hytale/` directory before building.

---

## Contributing & PRs ✅

Contributions are welcome. Open an issue or a PR.

---

## License 📜

This repository is licensed under the Apache License 2.0. See `LICENSE` for details.
