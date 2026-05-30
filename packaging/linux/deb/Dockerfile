FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/flutter/bin:${PATH}"
ENV FLUTTER_SUPPRESS_ANALYTICS=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    clang \
    cmake \
    curl \
    desktop-file-utils \
    file \
    git \
    libgtk-3-dev \
    make \
    ninja-build \
    pkg-config \
    ruby \
    ruby-dev \
    unzip \
    xz-utils \
    zip \
  && rm -rf /var/lib/apt/lists/*

RUN gem install --no-document fpm

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /opt/flutter \
  && flutter config --enable-linux-desktop \
  && flutter precache --linux \
  && chmod -R a+rwX /opt/flutter

WORKDIR /work
