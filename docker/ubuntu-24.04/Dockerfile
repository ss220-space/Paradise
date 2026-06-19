FROM ubuntu:24.04 as base

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt install -y libcurl4:i386 libgcc-s1:i386 \
            zlib1g-dev:i386 \
            lib32gcc-11-dev \
            gcc-multilib g++-multilib \
            libc6-dev-i386 \
            libgcc-11-dev:i386 \
			jq

RUN apt install -y gh
RUN apt install -y rustup

RUN rustup default 1.29.0
RUN rustup target add i686-unknown-linux-gnu
