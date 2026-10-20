FROM etherpad/etherpad:2.1.1
# Pinned to the versions in schoolbox/epl:2.1.1-1. Unpinned names install the
# latest release at build time.
ARG ETHERPAD_PLUGINS="redis@6.1.0 ep_plugin_helpers@0.6.7 ep_disable_chat@0.0.53 ep_disable_change_author_name@0.0.74 ep_headings@0.1.6"
ARG API_KEY
ARG SESSION_KEY

ENV SESSION_KEY=$SESSION_KEY
ENV REQUIRE_SESSION=false
ENV EDIT_ONLY=true
ENV AUTHENTICATION_METHOD=apikey

# Stop trusting the roots behind the compromised eMudhra intermediates
# (https://emudhra.we-have-a-problem.com/). The base image is Alpine 3.20,
# which has no fixed ca-certificates package, so deselect them, rebuild the
# system store and check they are gone from the bundle and /etc/ssl/certs.
USER root
RUN set -eu; \
    roots="emSign_ECC_Root_CA_-_G3 Comodo_AAA_Services_root"; \
    for root in $roots; do \
        sed -i "s#^mozilla/$root\.crt\$#!mozilla/$root.crt#" /etc/ca-certificates.conf; \
        grep -qx "!mozilla/$root.crt" /etc/ca-certificates.conf; \
    done; \
    update-ca-certificates; \
    bundle=$(grep -v -- ----- /etc/ssl/certs/ca-certificates.crt | tr -d '\n'); \
    for root in $roots; do \
        cert=$(grep -v -- ----- "/usr/share/ca-certificates/mozilla/$root.crt" | tr -d '\n'); \
        case "$bundle" in *"$cert"*) echo "$root is still in the bundle" >&2; exit 1;; esac; \
        if ls -l /etc/ssl/certs | grep -F "$root" >&2; then \
            echo "$root is still linked in /etc/ssl/certs" >&2; exit 1; \
        fi; \
    done
USER etherpad

# Node trusts its own bundled copy of Mozilla's roots, which still includes
# these, unless told to use the system store fixed above
ENV NODE_OPTIONS=--use-openssl-ca

COPY entrypoint.sh /entrypoint.sh

RUN  pnpm run install-plugins ${ETHERPAD_PLUGINS}

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 9001
