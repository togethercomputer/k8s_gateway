FROM alpine:3.23

RUN apk add --no-cache ca-certificates

COPY coredns /

EXPOSE 53 53/udp
CMD ["/coredns"]
