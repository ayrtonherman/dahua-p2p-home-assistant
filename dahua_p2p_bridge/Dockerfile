ARG BUILD_FROM
FROM golang:1.25-alpine AS build
RUN apk add --no-cache git
WORKDIR /src
# Pin the reviewed DMSS-capable dh-fwd revision.
RUN git init . \
    && git remote add origin https://github.com/undervolter/dh-fwd.git \
    && git fetch --depth 1 origin c26ce4f4b7051bfd0b8d07d8a22400f52cb5142c \
    && git checkout --detach FETCH_HEAD
# The upstream binary binds forwarded ports to loopback. The add-on port
# mapping cannot reach that listener, so bind inside the container instead.
RUN sed -i 's/127\.0\.0\.1:%d/0.0.0.0:%d/' core/tunnel.go \
    && grep -q '0.0.0.0:%d' core/tunnel.go
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/dh-fwd .

FROM ${BUILD_FROM}
COPY --from=build /out/dh-fwd /usr/local/bin/dh-fwd
COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]
