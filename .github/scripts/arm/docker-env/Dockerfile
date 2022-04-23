# PostgREST docker hub image

FROM ubuntu:focal AS postgrest

RUN apt-get update -y \
    && apt install libpq-dev zlib1g-dev jq gcc libnuma-dev -y
    && apt-get clean \
    && rm

COPY postgrest /usr/bin/postgrest

EXPOSE 3000

USER 1000

CMD postgrest
