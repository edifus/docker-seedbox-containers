FROM ghcr.io/linuxserver/baseimage-alpine:3.14

LABEL maintainer="edifus"
LABEL org.opencontainers.image.source https://github.com/edifus/docker-seedbox-containers

# environment
ENV GOPATH="/go" \
    HOME="/config" \
    RCLONE_CONFIG="/config/rclone/rclone.conf" \
    MountPoint="/seedbox/merged" \
    RemotePath="union:" \
    UnmountCommands="-u -z" \
    ItemsPerUpload=100 \
    MaxGbPerUpload=25 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN apk --no-cache upgrade

RUN apk --no-cache add --virtual .rclone-build-deps unzip && \
    apk --no-cache add --virtual .rclone-run-deps ca-certificates fuse fuse-dev && \
    apk --no-cache add --virtual .run-deps findutils moreutils coreutils bash gettext cdrkit grep gawk curl && \
    curl https://rclone.org/install.sh | bash && \
    sed -i -e 's,#user_allow_other,user_allow_other,' /etc/fuse.conf && \
    apk del .rclone-build-deps && \
    rm -rf /usr/lib/go /go /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rclone/rootfs/ /
COPY healthcheck-mount /usr/sbin/

HEALTHCHECK --start-period=10s CMD /usr/sbin/healthcheck-mount
