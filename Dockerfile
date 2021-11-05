FROM node:lts-alpine

RUN apk --update --no-cache add python3 py3-pip jq curl bash git docker && \
    ln -sf /usr/bin/python3 /usr/bin/python

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
