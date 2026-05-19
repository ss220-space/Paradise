FROM ubuntu:24.04 AS base
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*


FROM base AS byond
WORKDIR /byond

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libcurl4:i386 \
        curl \
        unzip \
        make \
        libstdc++6:i386 \
    && rm -rf /var/lib/apt/lists/*

COPY _build_dependencies.sh .

RUN . ./_build_dependencies.sh \
    && curl -H "User-Agent: ParadiseSS1984/Paradise CI" "http://www.byond.com/download/build/${STABLE_BYOND_MAJOR}/${STABLE_BYOND_MAJOR}.${STABLE_BYOND_MINOR}_byond_linux.zip" -o byond.zip \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && sed -i 's|LIB_DIR = /usr/local/lib|LIB_DIR = /usr/lib|' Makefile \
    && make install \
    && chmod 644 /usr/local/byond/man/man6/* \
    && apt-get purge -y --auto-remove curl unzip make \
    && cd .. \
    && rm -rf byond byond.zip

FROM base AS rust
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal \
    && ~/.cargo/bin/rustup target add i686-unknown-linux-gnu \
    && rm -rf /var/lib/apt/lists/*


FROM base AS rust_g
WORKDIR /rust_g

COPY _build_dependencies.sh .

RUN . ./_build_dependencies.sh && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o ./librust_g.so "https://github.com/ss220-space/rust-g-tg/releases/download/$RUSTG_VERSION/librust_g.so"

FROM base AS nodejs

COPY _build_dependencies.sh .

RUN . ./_build_dependencies.sh && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_$(echo $NODE_VERSION | cut -d. -f1).x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*


FROM byond
WORKDIR /paradise

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libssl-dev:i386 \
        zlib1g:i386 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=rust_g /rust_g/librust_g.so ./librust_g.so

EXPOSE 3228

