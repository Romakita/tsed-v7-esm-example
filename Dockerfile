###############################################################################
###############################################################################
##                      _______ _____ ______ _____                           ##
##                     |__   __/ ____|  ____|  __ \                          ##
##                        | | | (___ | |__  | |  | |                         ##
##                        | |  \___ \|  __| | |  | |                         ##
##                        | |  ____) | |____| |__| |                         ##
##                        |_| |_____/|______|_____/                          ##
##                                                                           ##
## description     : Dockerfile for TsED Application                         ##
## author          : TsED team                                               ##
## date            : 2023-12-11                                              ##
## version         : 3.0                                                     ##
##                                                                           ##
###############################################################################
###############################################################################

ARG NODE_VERSION=20.11.0

FROM node:${NODE_VERSION}-alpine AS build
WORKDIR /opt

COPY package.json pnpm-lock.yaml tsconfig.json tsconfig.base.json tsconfig.node.json tsconfig.spec.json .barrels.json .swcrc ./

RUN pnpm install --frozen-lockfile

COPY ./src ./src

RUN pnpm run build

FROM node:${NODE_VERSION}-alpine AS runtime
ENV WORKDIR /opt
WORKDIR $WORKDIR

RUN apk update && apk add build-base git curl
RUN npm install -g pm2

COPY --from=build /opt .

RUN pnpm install --frozen-lockfile --prod

COPY . .

EXPOSE 8081
ENV PORT 8081
ENV NODE_ENV production

CMD ["pm2-runtime", "start", "processes.config.cjs", "--env", "production"]