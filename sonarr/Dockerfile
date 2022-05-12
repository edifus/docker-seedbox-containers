FROM ghcr.io/linuxserver/sonarr

LABEL maintainer="edifus"
LABEL org.opencontainers.image.source https://github.com/edifus/docker-seedbox-containers

COPY sonarr/40-symlink-logs /etc/cont-init.d/
COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
COPY healthcheck-web /etc/sbin/

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    HEALTHCHECK_PORT=8989

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
HEALTHCHECK --start-period=10s CMD /etc/cont-init.d/00-healthcheck-mount && /etc/sbin/healthcheck-web
