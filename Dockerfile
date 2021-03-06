FROM golang:alpine as builder

RUN apk add --no-cache make git && \
    git clone https://github.com/Dreamacro/clash.git /clash-src && \
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
WORKDIR /clash-src
COPY --from=tonistiigi/xx:golang / /
RUN go mod download && \
    make docker && \
    mv ./bin/clash-docker /clash

FROM alpine:latest

COPY --from=builder /Country.mmdb /root/.config/clash/
COPY --from=builder /clash /
COPY setup.sh /setup.sh

RUN apk add --no-cache ca-certificates tzdata bash iptables && \
    apk del --purge tzdata && \
    rm -rf /var/cache/apk/* && \
    chmod +x /setup.sh

ENV CONFIG_URL=https://your.config.url

ENTRYPOINT [ "/setup.sh" ]
CMD [ "/clash", "-d", "/root/.config/clash" ]