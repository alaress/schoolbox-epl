# Inspired by https://github.com/ether/etherpad-lite/blob/develop/Dockerfile
FROM node:alpine
LABEL version="2.0.3"
LABEL maintainer="IST Schoolbox <ist@schoolbox.com.au>"
ARG ETHERPAD_VERSION=2.0.3
ARG ETHERPAD_PLUGINS="redis ep_disable_chat ep_disable_change_author_name ep_headings"
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
ARG PAD_OPTIONS_SHOW_CHAT=false
ARG EP_HOME=
ARG EP_UID=5001
ARG EP_GID=0
ARG EP_SHELL=
ARG EP_DIR=/opt/etherpad-lite


ENV NODE_ENV=$NODE_ENV
ENV ETHERPAD_PRODUCTION=true
ENV SESSION_KEY=$SESSION_KEY
ENV REQUIRE_SESSION=$REQUIRE_SESSION
ENV EDIT_ONLY=$EDIT_ONLY
ENV LOGLEVEL=$LOGLEVEL

# Install packages
RUN  \
    mkdir -p /usr/share/man/man1 && \
    npm install pnpm@9.0.4 -g  && \
    apk update && apk upgrade && \
    apk add --no-cache \
    ca-certificates \
    curl \
    git  \
    shadow \ 
    bash

RUN groupadd --system ${EP_GID:+--gid "${EP_GID}" --non-unique} etherpad && \
    useradd --system ${EP_UID:+--uid "${EP_UID}" --non-unique} --gid etherpad \
    ${EP_HOME:+--home-dir "${EP_HOME}"} --create-home \
    ${EP_SHELL:+--shell "${EP_SHELL}"} etherpad

# Create etherpad-lite directory and own them
RUN mkdir -p "${EP_DIR}" && chown etherpad:etherpad "${EP_DIR}"

# Change working directory
WORKDIR "${EP_DIR}"

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
RUN bin/installDeps.sh && rm -rf ~/.npm && \
    pnpm run install-plugins ${ETHERPAD_PLUGINS} && \
    cp settings.json.docker settings.json

# Temporarily switch user to root for cleanup
USER root:root

RUN apk del ${PKGS_TO_DEL} && rm -rf ${DIRS_TO_DEL}

# Switch back to etherpad user
USER etherpad:etherpad

# Copy settings

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["pnpm", "run", "prod"]

EXPOSE 9001
