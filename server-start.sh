#!/bin/ash
set -euo pipefail
java -Xms2G -Xmx4G -XX:AOTCache=/hytale/Server/HytaleServer.aot --enable-native-access=ALL-UNNAMED -jar /hytale/Server/HytaleServer.jar --assets /hytale/Assets.zip