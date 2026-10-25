# Etherpad 2.1.1, rebased onto a Node release patched for CVE-2026-111497
# (Brotli decoder RCE). The upstream 2.1.1 image ships Node 22.4.0 on Alpine 3.20.
# The app itself is copied unchanged; only the Node runtime and OS layer change.
FROM etherpad/etherpad:2.1.1 AS etherpad

FROM node:22.23.4-alpine

# Recreate the upstream image's user (uid 5001, gid 0) and pnpm.
RUN adduser -D -u 5001 -G root etherpad
COPY --from=etherpad /usr/local/lib/node_modules/pnpm /usr/local/lib/node_modules/pnpm
RUN ln -s ../lib/node_modules/pnpm/bin/pnpm.cjs /usr/local/bin/pnpm \
    && ln -s ../lib/node_modules/pnpm/bin/pnpx.cjs /usr/local/bin/pnpx
COPY --from=etherpad --chown=etherpad:etherpad /opt/etherpad-lite /opt/etherpad-lite

USER etherpad
WORKDIR /opt/etherpad-lite
ENV NODE_ENV=production
ENV ETHERPAD_PRODUCTION=true

ARG ETHERPAD_PLUGINS="redis ep_disable_chat ep_disable_change_author_name ep_headings"
ARG API_KEY
ARG SESSION_KEY

ENV SESSION_KEY=$SESSION_KEY
ENV REQUIRE_SESSION=false
ENV EDIT_ONLY=true
ENV AUTHENTICATION_METHOD=apikey

COPY entrypoint.sh /entrypoint.sh

RUN  pnpm run install-plugins ${ETHERPAD_PLUGINS}

HEALTHCHECK --interval=5s --timeout=3s CMD wget -qO- http://127.0.0.1:9001/health | grep -E "pass|ok|up" > /dev/null || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 9001
