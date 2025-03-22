FROM node:23.10.0

WORKDIR /usr/src/app

COPY --chown=node:node . .
RUN npm ci
