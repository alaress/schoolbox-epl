#!/bin/sh

# Etherpad reads the API and session keys from these files at startup
echo "$API_KEY" >APIKEY.txt && echo "$SESSION_KEY" >SESSIONKEY.txt

# The base image's start command. Upstream stopped starting through pnpm
# (bin/run.sh) because pnpm can try to reinstall packages at startup and abort
# (ether/etherpad#7718). schoolbox-settings.json is merged over settings.json.
cd src && exec node --require tsx/cjs node/server.ts --credentials schoolbox-settings.json
