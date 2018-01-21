FROM bitwalker/alpine-elixir-phoenix AS BUILD_STEP

ENV MIX_ENV=prod

COPY . .

WORKDIR /opt/app

RUN mix local.hex --force \
  && mix local.rebar --force \
  && mix do deps.get --only prod \
  && mix deps.compile \
  && mix deps.clean --build ecto

RUN mix phx.digest

RUN mix release --env=prod --verbose

RUN find . -name *.tar.gz

## #####################################################################################################################
## Release

FROM elixir:1.5.1-slim

EXPOSE 4000
ENV PORT=4000 \
  MIX_ENV=prod \
  REPLACE_OS_VARS=true \
  SHELL=/bin/sh

ARG SOURCE_COMMIT=0
ENV COMMIT_HASH $SOURCE_COMMIT

WORKDIR /opt/app

COPY --from=BUILD_STEP /opt/app/_build/prod/rel/batch_process_coordination/releases/0.0.1/batch_process_coordination.tar.gz .
RUN tar zxf batch_process_coordination.tar.gz

ENTRYPOINT ["/opt/app/bin/batch_process_coordination"]
CMD ["foreground"]
