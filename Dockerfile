FROM ubuntu:xenial

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates

## BYOND INSTALL

WORKDIR /byond

ARG BYOND_MAJOR
ARG BYOND_MINOR

ENV BYOND_LINUX_URL="http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip"

RUN apt-get install -y --no-install-recommends \
        curl \
        unzip \
        make \
        libstdc++6:i386

RUN curl $BYOND_LINUX_URL -L -o byond.zip \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && make install \
    && chmod 644 /usr/local/byond/man/man6/* \
    && cd .. \
    && rm -rf byond byond.zip


## BUILD

# RUST
WORKDIR /rust_g

ARG RUSTG

RUN dpkg --add-architecture i386 \
    && apt-get install -y --no-install-recommends \
        pkg-config:i386 \
    	zlib1g-dev:i386 \
        libssl-dev:i386 \
        gcc-multilib \
        git

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile --default-toolchain=1.51.0 \
    && ~/.cargo/bin/rustup target add i686-unknown-linux-gnu

RUN git init \
    && git remote add origin https://github.com/ss220-space/rust-g-paradise \
    && git fetch --depth 1 origin "${RUSTG}" \
    && git checkout FETCH_HEAD \
    && env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --target i686-unknown-linux-gnu


# Copy file to container
COPY . /station

# Node
WORKDIR /station/tgui

ARG NODEJS
ENV NODEJS_LINK="https://deb.nodesource.com/setup_${NODEJS}.x"

RUN curl -sL $NODEJS_LINK -o nodesource_setup.sh \
	&& bash nodesource_setup.sh \
    && apt-get update \
    && rm -rf nodesource_setup.sh \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update

RUN apt-get -y install nodejs yarn

RUN yarn install && yarn build

## FINAL

# DreamMaker
ARG DREAM_MAKER_COMMAND="./tools/ci/dm.sh paradise.dme"

WORKDIR /station
RUN ${DREAM_MAKER_COMMAND}

# Run server
RUN apt-get install -y --no-install-recommends \
        libssl1.0.0:i386 \
        zlib1g:i386

RUN cp /rust_g/target/i686-unknown-linux-gnu/release/librust_g.so /station/librust_g.so

VOLUME [ "/station/config", "/station/data" ]
ENTRYPOINT DreamDaemon paradise.dmb -port 1337 -trusted -close -verbose
EXPOSE 1337
