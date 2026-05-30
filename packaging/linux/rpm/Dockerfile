FROM fedora:latest

ENV PATH="/opt/flutter/bin:${PATH}"
ENV FLUTTER_SUPPRESS_ANALYTICS=true

RUN dnf install -y \
    bash \
    ca-certificates \
    clang \
    cmake \
    curl \
    desktop-file-utils \
    file \
    findutils \
    gcc \
    gcc-c++ \
    git \
    gtk3-devel \
    make \
    ninja-build \
    pkgconf-pkg-config \
    redhat-rpm-config \
    rpm-build \
    ruby \
    ruby-devel \
    unzip \
    which \
    xz \
    zip \
  && dnf clean all

RUN gem install --no-document fpm

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /opt/flutter \
  && flutter config --enable-linux-desktop \
  && flutter precache --linux \
  && chmod -R a+rwX /opt/flutter

WORKDIR /work
