ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache nodejs npm

RUN npm install --global dahua-p2p@1.0.0

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
