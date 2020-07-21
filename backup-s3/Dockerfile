ARG BUILD_FROM
FROM $BUILD_FROM:3.12.0

ENV LANG C.UTF-8

# add aws-cli and deps
RUN apk -v --update --no-cache add \
        py-pip \
        groff \
        less \
        mailcap \
        && \
    pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic && \
    apk -v --purge del py-pip
RUN apk add jq

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
