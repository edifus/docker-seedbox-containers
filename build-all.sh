#!/bin/bash
set -ex

docker build -t edifus/gcloud_init -f gcloud_init/Dockerfile .

docker build -t edifus/rclone_generate_keys -f rclone_generate_keys/Dockerfile .

docker build -t edifus/rclone -f rclone/Dockerfile .

docker build -t edifus/radarr -f radarr/Dockerfile .

docker build -t edifus/sonarr -f sonarr/Dockerfile .

docker build -t edifus/filebot -f filebot/Dockerfile .

#docker build -t edifus/bazarr -f bazarr/Dockerfile .

#docker build -t edifus/traktarr -f traktarr/Dockerfile .

#docker build -t edifus/headphones -f headphones.Dockerfile .

#docker build -t edifus/lazylibrarian -f lazylibrarian.Dockerfile .

#docker build -t edifus/medusa -f medusa.Dockerfile .

#docker build -t edifus/mylar -f mylar.Dockerfile .

#docker build -t edifus/nzbhydra2 -f nzbhydra2.Dockerfile .

#docker build -t edifus/sabnzbd -f sabnzbd.Dockerfile .

#docker build -t edifus/transmission -f transmission.Dockerfile .
