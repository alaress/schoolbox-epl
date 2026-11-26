FROM etherpad/etherpad:3.3.22

# Pinned so a rebuild installs the same plugins. ep_plugin_helpers is a
# dependency of ep_disable_chat and ep_headings2, pinned so it is not resolved
# to its latest release at build time. Etherpad 3 ships the Redis driver, so it
# is no longer installed as a plugin.
#
# ep_headings (last released in 2013) stops the pad loading on Etherpad 3.
# ep_headings2 replaces it and reads the same "heading" line attribute, so
# existing pads keep their headings (h5 and h6 show as h4).
ARG ETHERPAD_PLUGINS="ep_plugin_helpers@0.6.9 ep_disable_chat@0.0.56 ep_disable_change_author_name@0.0.76 ep_headings2@0.2.135"
ARG SESSION_KEY

ENV SESSION_KEY=$SESSION_KEY
ENV REQUIRE_SESSION=false
ENV EDIT_ONLY=true
ENV AUTHENTICATION_METHOD=apikey

# Settings Etherpad 3 added, set so the pad looks and behaves as it did on 2.1.1
# - dark mode would follow the browser's theme inside Schoolbox's light page
# - the updater polls GitHub and serves the running version at
#   /admin/update/status and /api/version-status without authentication
# - metrics serve /stats and /stats/prometheus without authentication
# - the update check calls etherpad.org every hour
ENV ENABLE_DARK_MODE=false
ENV UPDATES_TIER=off
ENV ENABLE_METRICS=false
ENV PRIVACY_UPDATE_CHECK=false

COPY entrypoint.sh /entrypoint.sh
COPY --chown=etherpad:etherpad schoolbox-settings.json ./

RUN pnpm run plugins i ${ETHERPAD_PLUGINS}

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 9001
