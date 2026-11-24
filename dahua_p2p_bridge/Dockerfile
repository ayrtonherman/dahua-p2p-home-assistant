ARG BUILD_FROM
FROM golang:1.25-alpine AS build
RUN apk add --no-cache git python3
WORKDIR /src
# Pin the reviewed DMSS-capable upstream release.
RUN git init . \
    && git remote add origin https://github.com/undervolter/dh-fwd.git \
    && git fetch --depth 1 origin a8b2ab9c850be3bd673513c43f30b1a2499d5e47 \
    && git checkout --detach FETCH_HEAD
COPY patch_dh_fwd.py /tmp/patch_dh_fwd.py
RUN python3 /tmp/patch_dh_fwd.py \
    && go test ./...
# Home Assistant publishes the container port, so bind the forwarded RTSP
# listener on all container interfaces instead of upstream's loopback only.
RUN sed -i 's/127[.]0[.]0[.]1:%d/0.0.0.0:%d/' core/tunnel.go \
    && grep -q '0.0.0.0:%d' core/tunnel.go
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/dh-fwd .

FROM ${BUILD_FROM}
COPY --from=build /out/dh-fwd /usr/local/bin/dh-fwd
COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]
