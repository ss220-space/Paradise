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

RUN bash ./_build_dependencies.sh
RUN echo "Installing BYOND"
RUN bash ./install_byond.sh STABLE

RUN apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
RUN chmod +x ~/.nvm/nvm.sh
RUN ~/.nvm/nvm.sh install v22.11.0
RUN ~/.nvm/nvm.sh use v22.11.0
RUN apt install npm -y
RUN npm install --global yarn
RUN yarn set version 4.8.1
RUN apt install -y python3.13
RUN add-apt-repository ppa:dotnet/backports

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.13 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1

RUN apt install -y python3-pip
RUN pip install json5 --break-system-packages
RUN pip install setuptools --break-system-packages

COPY tools/requirements.txt .
RUN pip install -r requirements.txt
RUN apt-get update
RUN apt install -y dotnet-sdk-10.0
