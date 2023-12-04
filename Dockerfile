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
        linux-headers

# Create dirs and add the build script
RUN mkdir -p /usr/src/libpq
ADD compat/libpq.sh /usr/src/libpq/build.sh
RUN chmod +x /usr/src/libpq/build.sh
WORKDIR /usr/src/libpq

# Build
ARG POSTGRES_VERSION=15.5
RUN ./build.sh "${POSTGRES_VERSION}" /usr/src/libpq/install

# Profit
WORKDIR /usr/src/libpq/install
RUN tar -czf /usr/src/libpq/libpq.tar.gz *

# smol image
FROM scratch

# Copy the file
COPY --from=builder /usr/src/libpq/libpq.tar.gz /libpq.tar.gz
