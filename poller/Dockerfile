FROM alpine:latest
RUN apk add --no-cache curl jq
COPY poller.sh /poller.sh
RUN chmod +x /poller.sh
CMD ["/poller.sh"]