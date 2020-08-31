# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2020 Hyperwarp Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:focal

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get upgrade -y \
    && apt-get -y install --no-install-recommends build-essential pkg-config zip unzip cmake autoconf automake libtool curl make g++ ca-certificates git

# Install FoundationDB
RUN curl -L https://www.foundationdb.org/downloads/6.2.22/ubuntu/installers/foundationdb-clients_6.2.22-1_amd64.deb -o /tmp/foundationdb-clients_6.2.22-1_amd64.deb \
    && curl -L https://www.foundationdb.org/downloads/6.2.22/ubuntu/installers/foundationdb-server_6.2.22-1_amd64.deb -o /tmp/foundationdb-server_6.2.22-1_amd64.deb \
    && apt install /tmp/foundationdb-clients_6.2.22-1_amd64.deb /tmp/foundationdb-server_6.2.22-1_amd64.deb -y \
    && rm -rf /tmp/foundationdb-*.deb

# Install protobuf
RUN curl -L https://github.com/protocolbuffers/protobuf/releases/download/v3.13.0/protobuf-cpp-3.13.0.tar.gz -o /tmp/protobuf-cpp-3.13.0.tar.gz \
    && cd /tmp \
    && tar xzf /tmp/protobuf-cpp-3.13.0.tar.gz \
    && cd /tmp/protobuf-3.13.0 \
    && ./configure \
    && make \
    && make check \
    && make install \
    && ldconfig \
    && rm -rf /tmp/protobuf-3.13.0

# Install protobuf-c
RUN curl -L https://github.com/protobuf-c/protobuf-c/releases/download/v1.3.3/protobuf-c-1.3.3.tar.gz -o /tmp/protobuf-c-1.3.3.tar.gz \
    && cd /tmp \
    && tar xzf /tmp/protobuf-c-1.3.3.tar.gz \
    && cd /tmp/protobuf-c-1.3.3 \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /tmp/protobuf-c-1.3.3

RUN git clone -b v20.07 --depth 1 https://github.com/spdk/spdk /tmp/spdk \
    && cd /tmp/spdk \
    && git submodule update --init \
    && ./scripts/pkgdep.sh --all \
    && ./configure --with-rdma --with-shared \
    && make \
    && make install \
    && cd ./isa-l && make install && cd .. \
    && ldconfig -v -n ./dpdk/build-tmp/lib ./build/lib
