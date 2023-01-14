FROM ubuntu:latest AS base

RUN set -e

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -y --no-install-recommends cmake clang g++ gcc git llvm-dev make python3

COPY . /opt/vamos
WORKDIR /opt/vamos

FROM base as compile
ENV GIT_SSL_NO_VERIFY=1
# We have troubles building dynamo rio, should we download it?
RUN make sources-init && make -j4 -C vamos-sources/ext dynamorio BUILD_TYPE=Release
RUN make -j4 BUILD_TYPE=Release

#FROM compile AS release
#COPY --from=build /opt/vamos /opt/vamos
#WORKDIR /opt/vamos

