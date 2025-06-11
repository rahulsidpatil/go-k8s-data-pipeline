# go-k8s-data-pipeline
Building high performance data pipeline with Go and k8s

# Building Scalable Data Pipelines: Using Go, Kafka (KRaft Mode), and Kubernetes

### Introduction

In today’s data-driven world, businesses generate massive amounts of data every second. Processing, transforming, and managing this data efficiently requires **scalable data pipelines**. If you're an absolute beginner and wondering how to build such a pipeline using **Go, Kafka (in KRaft mode), MongoDB, and Kubernetes**, this guide is for you!

We’ll walk through the **fundamentals of data pipelines**, the **role of Go, Kafka (KRaft), and Kubernetes**, and how to build a **simple, scalable data pipeline** step by step.

---

## Understanding Data Pipelines

A **data pipeline** is a set of processes that ingest, process, transform, and store data efficiently. Common components include:

1. **Data Ingestion** – Collecting raw data from different sources.
2. **Processing & Transformation** – Cleaning, filtering, and processing data.
3. **Storage** – Saving processed data in databases or cloud storage.
4. **Serving & Visualization** – Making data available for analytics, dashboards, or other applications.

Modern data pipelines should be **scalable, resilient, and fault-tolerant**—which is where **Go, Kafka (KRaft mode), MongoDB, and Kubernetes** come into play.

---

## building go-k8s-data-pipeline

A step-by-step guide to build and run a high-performance data pipeline using **Go**, **Kafka (KRaft Mode)**, **MongoDB**, and **Kubernetes** via **Minikube**.

---

## 🧱 Components Overview

| Component        | Description |
|------------------|-------------|
| `dummy-producer` | Continuously produces dummy data to Kafka topic. |
| `etl-consumer` | ETL app written in Go that consumes from Kafka and writes to MongoDB. |
| `kafka-cluster`  | Kafka setup (in KRaft mode) using Helm in Kubernetes. |
| `mongodb`        | MongoDB deployed in Kubernetes. |
| `Makefile`       | Automates the full setup, verification, and teardown processes. |

---

## ⚙️ Prerequisites

Make sure the following are installed:

- WSL2 Ubuntu 22.04 or native Linux
- Docker
- [Go](https://go.dev/dl/)
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- `make` command

---

## 🚀 Step-by-Step Setup Using Makefile

All steps below can be executed using:

```bash
make <target-name>
```

---

### ✅ Step 1: Install Required Tools

```bash
make install-go          # Installs Go
make verify-go           # Verifies Go installation

make install-minikube    # Installs Minikube
make verify-minikube     # Verifies Minikube installation
```

---

### 🚀 Step 2: Start Minikube Cluster

```bash
make minikube-start      # Starts Minikube with 4 CPUs and 8192MB memory
```

Optional:

```bash
make minikube-verify # verify minikube version and status
make k8s-check #verify minikube k8s cluster deployment
make minikube-enable-metrics-server #enable minikube metrics server
make minikube-dashboard  # Launch Minikube dashboard

```

---

### 📦 Step 3: Deploy Kafka in KRaft Mode

```bash
make kafka-install       # Installs Kafka using Bitnami Helm with KRaft mode
make kafka-verify        # Verifies Kafka setup
```

---

### 🍃 Step 4: Deploy MongoDB

```bash
make mongo-install       # Deploys MongoDB on Kubernetes
make mongo-verify        # Verifies MongoDB deployment
```

---

### 💾 Step 5: Deploy Dummy Data Producer

```bash
make dummy-data-generator-install  # Deploys Go-based dummy Kafka producer
make dummy-data-generator-verify        # Verifies dummy producer pod
```

---

### ⚙️ Step 6: Deploy ETL Go Application

```bash
make etl-consumer-install   # Deploys the ETL service that reads from Kafka and writes to MongoDB
make etl-consumer-verify          # Verifies ETL service
```


---

## 📊 Optional: Setup HPA for ETL App

```bash
kubectl autoscale deployment etl-consumer --cpu-percent=50 --min=1 --max=10
```

---

## 🧪 Optional: Benchmarking

You may simulate load on Kafka by adjusting the dummy producer frequency or using tools like `k6`.

---

## 🧹 Teardown / Cleanup

```bash
make stop-minikube       # Stops the Minikube cluster
make delete-minikube     # Deletes the Minikube cluster
make delete-kafka        # Uninstalls Kafka
make delete-mongo        # Deletes MongoDB
make delete-dummy        # Deletes dummy producer
make delete-etl          # Deletes ETL app
make clean               # Deletes all above
```

---

## 🧠 Architecture Diagram

```
+-------------------+        +-----------+        +-----------+        +---------+
| Dummy Producer    |----->  |  Kafka    |----->  |  ETL Go   |----->  | MongoDB |
+-------------------+        +-----------+        +-----------+        +---------+
```

---

# 📊 Benchmarking Report: go-k8s-data-pipeline

This document outlines how to benchmark the solution and records example metrics from a test run on the following system:

## 🖥️ System Configuration

**Host Machine:**
- OS: Windows 11 (64-bit)
- CPU: Intel Core i7-1165G7 @ 2.80GHz
- RAM: 32 GB

**Guest Machine (WSL2 Ubuntu 22.04):**
- Docker: Docker Desktop 4.41.2
- Kubernetes: Minikube v1.33.1
- Go version: 1.21+

---

## 🧪 Benchmark Objectives

- Measure throughput from Producer → Kafka → ETL → MongoDB
- Monitor latency and message lag
- Track CPU and Memory usage of pods
- Verify auto-scaling behavior under load (optional)

---

## ⚙️ Benchmark Methodology

### 1. Producer Load Configuration

```go
// burst-mode simulation (1000 messages)
for i := 0; i < 1000; i++ {
    msg := fmt.Sprintf("Benchmark-%d", i)
    p.Produce(&kafka.Message{TopicPartition: tp, Value: []byte(msg)}, nil)
}
```

### 2. Kafka Consumer Lag

Command:
```bash
kubectl exec -it <etl-pod> -- kafka-consumer-groups.sh   --bootstrap-server kafka.kafka.svc.cluster.local:9092   --describe --group etl-group
```

### 3. MongoDB Insert Rate

Command:
```bash
kubectl exec -it <mongo-pod> -- mongo --eval 'db.data.stats()'
```

### 4. Pod Resource Usage

```bash
kubectl top pods
```

---

## 📈 Sample Benchmark Results

### 🔹 Producer → Kafka Throughput

- Messages Sent: 1000
- Average Rate: ~950 msgs/sec
- Duration: ~1.1 sec

### 🔹 Kafka → MongoDB ETL

- Consumer Lag: 0 (fully consumed)
- Inserted Docs: 1000
- Insertion Time: ~1.5 sec

### 🔹 Resource Utilization

| Pod                  | CPU (millicores) | Memory (MiB) |
|----------------------|------------------|--------------|
| dummy-producer       | 120              | 70           |
| logstream-service    | 160              | 95           |
| kafka-controller-0   | 300              | 250          |
| mongodb              | 110              | 130          |

---

## 🧪 Observations

- End-to-end latency for a message ≈ 30–50ms under burst load.
- No message drops observed.
- MongoDB write throughput consistent with producer rate.

---

## ✅ Conclusion

This pipeline handled **1000 messages/sec** with consistent throughput and minimal lag. Suitable for light to moderate real-time data processing. Scaling strategies like HPA and message batching can improve higher load performance.

---



## 📎 Resources

- [Go](https://go.dev/)
- [Kafka KRaft Mode](https://kafka.apache.org/documentation/#kraft)
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [Bitnami Kafka Helm Chart](https://bitnami.com/stack/kafka/helm)

---

## 📝 License

MIT License

