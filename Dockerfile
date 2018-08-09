FROM alpine:3.8
LABEl maintainer "0x4FCA"
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG BUILD_USER="build"

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY

RUN apk update && \
    apk add --virtual build-dependencies alpine-sdk git diffutils && \
    adduser -D $BUILD_USER && \
    adduser $BUILD_USER abuild && \
    sudo -iu $BUILD_USER abuild-keygen -a && \
    sudo -iu $BUILD_USER https_proxy=$HTTPS_PROXY git clone --depth=1 -b pr-llvm-6 https://github.com/xentec/aports && \
    sudo -iu $BUILD_USER http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY sh -xec 'cd aports/main/llvm6; abuild -r' && \
    cp /home/$BUILD_USER/.abuild/*.rsa.pub /etc/apk/keys && \
    apk add /home/$BUILD_USER/packages/main/$(uname -m)/*.apk && \
    rm /home/$BUILD_USER/package/main/$(uname -m)/*.apk && \
    sudo -iu $BUILD_USER http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY sh -xec 'cd aports/main/clang; abuild -r' && \
    cp /home/$BUILD_USER/.abuild/*.rsa.pub /etc/apk/keys && \
    apk add /home/$BUILD_USER/packages/main/$(uname -m)/*.apk && \
    deluser --remove-home $BUILD_USER && \
    rm -rf /var/cache/apk/APKINDEX* && \
    apk del --no-cache build-dependencies
