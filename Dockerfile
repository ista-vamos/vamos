FROM ubuntu:latest

RUN set -e

COPY . /opt/vamos

WORKDIR /opt/vamos


# Getting the updates for Ubuntu and installing python into our environment
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update  && apt-get install -y python3 make cmake llvm clang gcc g++ git
RUN make sources-init
RUN make -j4 -C vamos-sources/ext dynamorio BUILD_TYPE=RelWithDebInfo
RUN make -j4
RUN make -j4 test

# CMD ["/bin/bash"]
