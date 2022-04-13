# Simple image to generate the PostgREST binaries

FROM scratch as postgrest-bin

COPY --from=postgrest-build /build-export /



# PostgREST docker hub image

FROM ubuntu:focal AS postgrest

RUN apt-get update -y
RUN apt install libpq-dev zlib1g-dev jq gcc libnuma-dev -y
RUN apt-get clean

COPY --from=postgrest-bin postgrest /usr/bin/postgrest

EXPOSE 3000

USER 1000

CMD postgrest
