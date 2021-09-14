FROM alpine:3.13

RUN apk --update --no-cache add nodejs python3 py3-pip jq curl bash git docker && \
    apk add --no-cache npm=7.17.0-r0 && \
    ln -sf /usr/bin/python3 /usr/bin/python

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
