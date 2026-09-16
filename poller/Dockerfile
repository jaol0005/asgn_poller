FROM alpine:latest

RUN apk add --no-cache curl

WORKDIR /poller

COPY poller.sh .

RUN chmod +x poller.sh

CMD ["./poller.sh"]
