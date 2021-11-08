FROM mhart/alpine-node:16

RUN apk --update --no-cache add python3 py3-pip jq curl bash git docker && \
    ln -sf /usr/bin/python3 /usr/bin/python && npm install -g aws-cdk

#RUN chown -R 1001:121 "/.npm"
USER 1001:121
#RUN npm config set user 0 && npm config set unsafe-perm true

COPY entrypoint.sh /entrypoint.sh
ADD heimdallr /heimdallr

#ENTRYPOINT ["/entrypoint.sh"]
