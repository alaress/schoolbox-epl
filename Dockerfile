# Inspired by https://github.com/ether/etherpad-lite/blob/develop/Dockerfile
FROM node:alpine3.11
LABEL version="1.8.3"
LABEL maintainer="IST Schoolbox <ist@schoolbox.com.au>"

ARG ETHERPAD_VERSION=1.8.3
ARG ETHERPAD_PLUGINS="redis ep_disable_change_author_name ep_headings"
ARG PKGS_TO_DEL="make gcc g++ linux-headers openssl" 
ARG DIRS_TO_DEL="/var/cache/apk/*" 
ARG PAD_BUILD_DEPENDENCY="openssl openssl-dev pcre pcre-dev zlib zlib-dev"
ARG NODE_ENV="production"
ARG API_KEY
ARG SESSION_KEY
# As for our use case, we are setting these values to true...
ARG REQUIRE_SESSION=true
ARG EDIT_ONLY=true
ARG LOGLEVEL="ERROR"

ENV NODE_ENV=$NODE_ENV
ENV API_KEY=$API_KEY
ENV SESSION_KEY=$SESSION_KEY
ENV REQUIRE_SESSION=$REQUIRE_SESSION
ENV EDIT_ONLY=$EDIT_ONLY
ENV LOGLEVEL=$LOGLEVEL

# Install packages
RUN apk add -U curl openssl

# Create etherpad group
RUN addgroup -g 5001 -S etherpad

# Create etherpad user under etherpad group
RUN adduser -u 5001 -S etherpad -G etherpad

# Create etherpad-lite directory and own them
RUN mkdir /opt/etherpad-lite && chown etherpad:etherpad /opt/etherpad-lite

# Change working directory
WORKDIR /opt/etherpad-lite

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Swith to etherpad user
USER etherpad:etherpad

# Create an empty APIKEY.txt and SESSIONKEY.txt file. This will be populated later from the environment variable. Not sure why echo doesn't work here..
# Harcoding the value in the ENV or ARG declaration works fine, but ofcourse we don't want to do that here as it is considered a credential.
RUN touch APIKEY.txt SESSIONKEY.txt

# Download, extract and delete tarball
RUN curl -L https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.tar.gz -o etherpad-${ETHERPAD_VERSION}.tar.gz \ 
    && tar -xf etherpad-${ETHERPAD_VERSION}.tar.gz --strip-components=1 \ 
    && rm etherpad-${ETHERPAD_VERSION}.tar.gz

# Install dependencies and remove npm cache
RUN bin/installDeps.sh && rm -rf ~/.npm/_cacache

# Install plugins
RUN for PLUGIN_NAME in ${ETHERPAD_PLUGINS}; do npm install "${PLUGIN_NAME}"; done

# Temporarily switch user to root for cleanup
USER root:root
RUN apk del ${PKGS_TO_DEL} && rm -rf ${DIRS_TO_DEL}

# Switch back to etherpad user
USER etherpad:etherpad

# Copy settings
COPY --chown=etherpad:etherpad ./settings.json.docker /opt/etherpad-lite/settings.json

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["node", "src/node/server.js"]

EXPOSE 9001
