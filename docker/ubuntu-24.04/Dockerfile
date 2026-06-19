FROM ubuntu:24.04 AS base
SHELL ["/bin/bash", "-c"]

ENV DOCKER_BUILD=true

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt install -y libcurl4:i386 libgcc-s1:i386 \
            zlib1g-dev:i386 \
            lib32gcc-11-dev \
            gcc-multilib g++-multilib \
            libc6-dev-i386 \
            libgcc-11-dev:i386 \
			jq \
			gh \
			rustup \
			curl \
			wget \
			unzip \
			file \
			make

RUN rustup default 1.29.0
RUN rustup target add i686-unknown-linux-gnu

COPY _build_dependencies.sh .
COPY tools/ci/install_byond.sh .

RUN ./_build_dependencies.sh
RUN echo "Installing BYOND"
RUN ./install_byond.sh STABLE
RUN source /root/BYOND/byond/bin/byondsetup

RUN apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install -y python3.13
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.13 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1

