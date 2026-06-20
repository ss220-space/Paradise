FROM ubuntu:24.04 AS base
SHELL ["/bin/bash", "-c"]

ENV DOCKER_BUILD=true

COPY _build_dependencies.sh .
COPY tools/ci/install_byond.sh .
COPY tools/requirements.txt .

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    add-apt-repository -y ppa:dotnet/backports && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libcurl4:i386 libgcc-s1:i386 \
        zlib1g-dev:i386 \
        lib32gcc-11-dev \
        gcc-multilib g++-multilib \
        libc6-dev-i386 \
        libgcc-11-dev:i386 \
        jq gh rustup curl wget unzip file make \
        python3.13 python3.13-venv python3-pip \
        dotnet-sdk-10.0 git && \
    rm -rf /var/lib/apt/lists/*

RUN rustup default 1.29.0 && \
    rustup target add i686-unknown-linux-gnu && \
    rm -rf ~/.cargo/registry ~/.rustup

RUN bash ./_build_dependencies.sh && \
    bash ./install_byond.sh STABLE && \
    rm -f _build_dependencies.sh install_byond.sh

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install --global yarn && \
    yarn set version 4.8.1 && \
    rm -rf /var/lib/apt/lists/* /usr/lib/node_modules/npm /usr/lib/node_modules/yarn/.cache

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.13 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1 && \
    pip install json5 setuptools -r requirements.txt --break-system-packages

