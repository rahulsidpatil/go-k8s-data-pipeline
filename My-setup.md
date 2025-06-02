# Go + Kubernetes Data Pipeline

This project demonstrates a high-performance data pipeline using Go, Kafka, MongoDB, and Kubernetes (Minikube).

## Components
- Dummy Data Producer (Go)
- ETL Consumer (Go)
- Kafka (via Helm)
- MongoDB (via Helm)
- Minikube (local K8s)

## Setup
Follow the guide to build, deploy, benchmark, and monitor your pipeline.

## Benchmark
Run:
```bash
chmod +x scripts/benchmark.sh
./scripts/benchmark.sh
```

## License
MIT


---

# 🛠️ Implementation Guide

This section provides a detailed walkthrough to set up, run, and benchmark the Go + Kubernetes data pipeline on a WSL2 Ubuntu 22.04 environment.

## 1️⃣ System Requirements

**Host Machine**:  
- Intel i7-1165G7, 32GB RAM, Windows 64-bit  
- Docker Desktop 4.41.2  
- Minikube v1.33.1  

**Guest Machine (WSL2)**:  
- Ubuntu 22.04  
- Docker + Kubernetes CLI tools

## 2️⃣ Install Prerequisites

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git make build-essential
```

## 3️⃣ Install Go

```bash
wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
go version
```

## 4️⃣ Install Kubernetes CLI

```bash
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

## 5️⃣ Install Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --driver=docker --cpus=4 --memory=8192
```

## 6️⃣ Build and Deploy Services

### Build Docker Images

```bash
cd dummy-producer
docker build -t dummy-producer:latest .
minikube image load dummy-producer:latest

cd ../etl-consumer
docker build -t etl-consumer:latest .
minikube image load etl-consumer:latest
```

### Deploy Kafka and MongoDB

```bash
kubectl create namespace kafka
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install kafka bitnami/kafka --namespace kafka

kubectl create namespace mongo
helm install mongodb bitnami/mongodb --namespace mongo
```

### Deploy Producer and Consumer
```bash
kubectl apply -f k8s/producer-deployment.yaml
kubectl apply -f k8s/consumer-deployment.yaml
```

## 7️⃣ Benchmarking

```bash
chmod +x scripts/benchmark.sh
./scripts/benchmark.sh
```

## 8️⃣ Recording the Demo

Use **OBS Studio** to screen record the terminal with:
- Minikube dashboard
- Pod logs
- Benchmark script execution
- Kafka and MongoDB pod statuses

---
