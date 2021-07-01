# Builder stage
FROM node:lts-alpine AS build

WORKDIR /app

RUN apk add --no-cache curl
# install node prune
RUN curl -sf https://gobinaries.com/tj/node-prune | sh

COPY package.json yarn.lock /app/

RUN yarn install --immutable --non-interactive

COPY . /app/

RUN yarn build

ENV NODE_ENV=production
RUN yarn --immutable --non-interactive --production
RUN node-prune

# Deploy stage
FROM gcr.io/distroless/nodejs

ADD package.json ./
ADD nuxt.config.js ./

COPY --from=build ./app/node_modules ./node_modules/
COPY --from=build ./app/.nuxt ./.nuxt/
# COPY --from=build ./app/src/static ./src/static/

ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=5000
EXPOSE 5000

CMD [ "node_modules/.bin/nuxt", "start" ]