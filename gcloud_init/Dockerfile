FROM google/cloud-sdk:alpine

WORKDIR /app

ENV PROJECT_NAME_PREFIX="seedbox-" \
    EXPORT_LOCATION="/mnt" \
    NUM_OF_SA=100 \
    SA_EMAIL_PREFIX="seedbox"

RUN apk --no-cache add bash
COPY gcloud_init/generate.sh ./

CMD ./generate.sh
