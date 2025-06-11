# Stage 1: Build the Go binary
FROM golang:1.22 as builder

WORKDIR /app

# Copy go.mod and go.sum first to cache dependencies
COPY go.mod go.sum ./

RUN go mod download

# Now copy the rest of your source code
COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o dummy-producer ./producer.go

# Stage 2: Base on Bitnami Kafka image with tools
FROM bitnami/kafka:3.6.0

USER root

RUN install_packages \
    bash \
    curl \
    net-tools \
    iputils-ping \
    dnsutils \
    netcat \
    iproute2 \
    vim

COPY --from=builder /app/dummy-producer /opt/dummy-producer

# Set default environment variable
ENV SLEEP_INTERVAL_MS=5000

USER 1001

ENTRYPOINT ["/opt/dummy-producer"]
