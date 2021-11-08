FROM mhart/alpine-node:16

RUN apk --update --no-cache add python3 py3-pip jq curl bash git docker && \
    ln -sf /usr/bin/python3 /usr/bin/python

#RUN chown -R 1001:121 "/.npm"
#USER 1001:121

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
