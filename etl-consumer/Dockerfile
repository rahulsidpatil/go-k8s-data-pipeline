
# Stage 1: Build the Go app
FROM golang:1.22 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o etl-consumer .

# Stage 2: Final image with tools + app
FROM bitnami/kafka:3.6.0

USER root

# Install Mongo CLI + debug tools
RUN install_packages \
    bash \
    curl \
    net-tools \
    iputils-ping \
    dnsutils \
    netcat \
    iproute2 \
    vim

COPY --from=builder /app/etl-consumer /opt/etl-consumer

USER 1001

ENTRYPOINT ["/opt/etl-consumer"]
