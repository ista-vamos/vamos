FROM ubuntu:latest AS base

RUN set -e

COPY . /opt/vamos

WORKDIR /opt/vamos

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -y --no-install-recommends cmake clang g++ gcc git llvm make python3  
#RUN make sources-init && make -j4 -C vamos-sources/ext dynamorio BUILD_TYPE=Release
# We have troubles building dynamo rio, should we download it?
RUN make -j4 BUILD_TYPE=Release DYNAMORIO_SOURCES=OFF && make -j4 test

#FROM base AS release
#COPY --from=build /opt/vamos /opt/vamos
#WORKDIR /opt/vamos

