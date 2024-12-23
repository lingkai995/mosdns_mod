FROM --platform=${TARGETPLATFORM} golang:alpine AS builder
ARG CGO_ENABLED=0
ARG TAG
ARG REPOSITORY

WORKDIR /root
RUN apk add --update git \
    && git clone https://github.com/${REPOSITORY} mosdns \
	&& cd ./mosdns \
	&& git fetch --all --tags \
	&& git checkout ${TAG} \
    && go build -ldflags "-s -w -X main.version=${TAG}" -trimpath -o mosdns

FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="IrineSistiana <github.com/IrineSistiana>"

COPY --from=builder /root/mosdns/mosdns /usr/bin/

RUN apk add --no-cache ca-certificates && \
    mkdir /etc/mosdns && \
    chown -R root:root /etc/mosdns && \
    apk --no-cache add curl && \
    apk --no-cache add dcron && \
    apk --no-cache add tzdata && \
    apk --no-cache add ncurses && \
    apk --no-cache add supervisor && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    echo "33 3 * * * /bin/sh /app/get_cn.sh > /proc/1/fd/1 2>&1" > /etc/crontabs/root

COPY ./get_cn.sh /app/
COPY ./supervisord.conf /app/
ENV PROXY=""

EXPOSE 53/udp 53/tcp
CMD ["/usr/bin/supervisord", "-c", "/app/supervisord.conf"]