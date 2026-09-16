FROM alpine:3.20

RUN apk add --no-cache curl

WORKDIR /app
COPY poller.sh .
RUN chmod +x poller.sh

ENTRYPOINT ["./poller.sh"]
