# 🧪 Benchmark Summary

This benchmark evaluates the performance of the Go + Kafka + MongoDB data pipeline on Kubernetes over a 1-minute run.

## ✅ Setup
- Namespace: `kafka`
- Duration: 60 seconds
- Sampling interval: 5 seconds

## 📊 Results

| Metric                         | Value     |
|-------------------------------|-----------|
| Messages sent to Kafka        | 1000      |
| Messages inserted to MongoDB  | 1000      |
| Duration                      | 60 seconds |

## 📉 Resource Utilization Snapshot

Captured from `kubectl top pod` every 5 seconds:

| Pod                  | Avg CPU | Avg Memory |
|----------------------|---------|-------------|
| dummy-producer       | ~120m   | ~70Mi       |
| etl-consumer         | ~160m   | ~95Mi       |
| mongodb              | ~110m   | ~130Mi      |

## 📁 Files
- [`run-benchmark.sh`](./run-benchmark.sh)
- [`benchmark-results.txt`](./benchmark-results.txt)
