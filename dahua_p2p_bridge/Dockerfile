ARG BUILD_FROM
FROM golang:1.25-alpine AS build
RUN apk add --no-cache git
WORKDIR /src
RUN git clone --depth 1 --branch v0.2 https://github.com/undervolter/dh-fwd.git .
# dh-fwd binds its forwarded TCP listener to loopback by default. Bind to all
# interfaces inside this isolated add-on container so HA can reach the port.
RUN sed -i 's/127\\.0\\.0\\.1:%d/0.0.0.0:%d/' core/tunnel.go
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/dh-fwd .

FROM ${BUILD_FROM}
COPY --from=build /out/dh-fwd /usr/local/bin/dh-fwd
COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]
