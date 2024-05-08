FROM etherpad/etherpad:2.0.1
ARG ETHERPAD_PLUGINS="redis ep_disable_chat ep_disable_change_author_name ep_headings"
ARG API_KEY
ARG SESSION_KEY

ENV SESSION_KEY=$SESSION_KEY
ENV REQUIRE_SESSION=false
ENV EDIT_ONLY=true

COPY entrypoint.sh /entrypoint.sh

RUN  pnpm run install-plugins ${ETHERPAD_PLUGINS}

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 9001
