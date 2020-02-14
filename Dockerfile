#----------------------------------------------------
# Base Alpine image
#----------------------------------------------------
FROM node:13.8.0-alpine3.11 as base
MAINTAINER Matthew Cuyar <matt@elumatherapy.com>

# Config Alpine
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    echo "UTC" | tee /etc/timezone && \
    apk del tzdata

# Base packages for Alpine
RUN apk add --no-cache bash git curl

# Add s6 Overlay
# @credit John Regan <john@jrjrtech.com>
# @original https://github.com/just-containers/s6-overlay

ARG s6_version=v1.22.0.0
RUN apk add --no-cache wget \
 && wget https://github.com/just-containers/s6-overlay/releases/download/${s6_version}/s6-overlay-amd64.tar.gz --no-check-certificate -O /tmp/s6-overlay.tar.gz \
 && tar xvfz /tmp/s6-overlay.tar.gz -C / \
 && rm -f /tmp/s6-overlay.tar.gz \
 && apk del wget

# Set FPM Log output to stderr
RUN mkdir -p /var/log/php7 \
 && touch /var/log/php7/fpm-error.log \
 && ln -sf /dev/stderr /var/log/php7/fpm-error.log

# Clean default site folder
RUN rm -rf /var/www/*

# Add the root file system
COPY rootfs /

# Set the work directory
WORKDIR /var/www

# Expose ports
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT [ "/init" ]