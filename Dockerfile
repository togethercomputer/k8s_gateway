FROM --platform=${BUILDPLATFORM} docker.io/library/golang:1.26.10-alpine3.23 AS builder

ARG LDFLAGS

WORKDIR /build

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

COPY cmd/ cmd/
COPY *.go ./

ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOARCH=$TARGETARCH
ENV GOOS=$TARGETOS

RUN go build -ldflags "${LDFLAGS}" -o coredns cmd/coredns.go

FROM scratch

COPY --from=docker.io/library/alpine:3.23 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /build/coredns .

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
