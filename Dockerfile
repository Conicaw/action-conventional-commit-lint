# --- base stage --- #

FROM alpine:3.16 AS base

RUN apk add --no-cache --update nodejs

RUN addgroup -S node && adduser -S node -G node

WORKDIR /action

ENTRYPOINT [ "node" ]

# --- build stage --- #

FROM base AS build

RUN apk add --no-cache npm

# slience npm
RUN npm config set update-notifier=false audit=false fund=false

# install packages
COPY action/package* ./
COPY action/install.js ./
RUN node install.js

# --- app stage --- #

FROM base AS app

LABEL com.github.actions.name="Conventional Commit Lint" \
      com.github.actions.description="commitlint your PRs with Conventional style" \
      com.github.actions.icon="search" \
      com.github.actions.color="red" \
      maintainer="Ahmad Nassri <ahmad@ahmadnassri.com>"


# copy from build image
COPY --from=build /usr/local/lib/node_modules /usr/lib/node
COPY --from=build --chown=node:node /action/node_modules ./node_modules

# copy files
COPY --chown=node:node action ./

USER node

CMD ["/action/index.js"]
