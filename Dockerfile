FROM elixir:latest


WORKDIR /app

COPY . /app/

RUN mix deps.get
RUN mix ecto.migrate


CMD [ "mix", "start" ]