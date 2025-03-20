FROM node:23-alpine3.20

WORKDIR /usr/src/app

COPY --chown=node:node . .
RUN npm ci

USER node
