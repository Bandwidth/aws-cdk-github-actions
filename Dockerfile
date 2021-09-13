FROM robertd/alpine-aws-cdk:1.115.0

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
