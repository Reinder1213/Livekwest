FROM elixir:1.18-alpine

RUN apk add --no-cache build-base npm git inotify-tools openssl postgresql-client

RUN mix local.hex --force && \
  mix local.rebar --force

WORKDIR /app
COPY . .

RUN mix deps.get