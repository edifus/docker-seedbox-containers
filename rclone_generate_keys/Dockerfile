FROM golang:alpine AS build

ENV GOPATH="/go"
WORKDIR /app
COPY rclone_generate_keys/main.go .
RUN apk add --no-cache alpine-sdk
RUN go install github.com/rclone/rclone/fs/config/obscure@latest && \
    go mod init obscure && \
    go mod tidy && \
    go build .

FROM alpine

LABEL maintainer="edifus"
LABEL org.opencontainers.image.source https://github.com/edifus/docker-seedbox-containers

COPY --from=build /app/obscure .
COPY rclone_generate_keys/run.sh .

ENTRYPOINT ["/run.sh"]
