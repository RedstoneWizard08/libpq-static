# Builds libpq statically.
FROM alpine as builder

# Install build tools
RUN apk update && \
    apk add --no-cache \
        alpine-sdk \
        gcc \
        mold \
        clang \
        llvm \
        binutils \
        lld \
        wget \
        tar \
        gzip \
        readline-dev \
        readline-static \
        zlib-dev \
        zlib-static \
        bash \
        sed \
        automake \
        autoconf \
        libtool \
        linux-headers \
        cmake \
        ninja

# Create dirs and add the build scripts
RUN mkdir -p /usr/src/libpq
ADD libpq.sh /usr/src/libpq/build.sh
ADD ncurses.sh readline.sh zlib.sh cmake /usr/src/libpq/
RUN chmod +x /usr/src/libpq/build.sh
WORKDIR /usr/src/libpq

# Build
ARG POSTGRES_VERSION=15.5
RUN ./build.sh "${POSTGRES_VERSION}" /usr/src/libpq/install-x86_64 x86_64-linux-gnu
RUN ./build.sh "${POSTGRES_VERSION}" /usr/src/libpq/install-arm64 aarch64-linux-gnu

# Profit
WORKDIR /usr/src/libpq/install-x86_64
RUN tar -czf /usr/src/libpq/libpq-x86_64.tar.gz *
WORKDIR /usr/src/libpq/install-aarch64
RUN tar -czf /usr/src/libpq/libpq-aarch64.tar.gz *
RUN cp -f "/usr/src/libpq/libpq-$(uname -m).tar.gz" /usr/src/libpq/libpq.tar.gz

# smol image
FROM scratch

# Copy the file
COPY --from=builder /usr/src/libpq/libpq.tar.gz /libpq.tar.gz
COPY --from=builder /usr/src/libpq/libpq-x86_64.tar.gz /libpq-x86_64.tar.gz
COPY --from=builder /usr/src/libpq/libpq-aarch64.tar.gz /libpq-aarch64.tar.gz
