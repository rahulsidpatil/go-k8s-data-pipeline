# go-k8s-data-pipeline
Building high performance data pipeline with Go and k8s

# Building Scalable Data Pipelines: Using Go, Kafka (KRaft Mode), and Kubernetes

### Introduction

In today’s data-driven world, businesses generate massive amounts of data every second. Processing, transforming, and managing this data efficiently requires **scalable data pipelines**. If you're an absolute beginner and wondering how to build such a pipeline using **Go, Kafka (in KRaft mode), MongoDB, and Kubernetes**, this guide is for you!

We’ll walk through the **fundamentals of data pipelines**, the **role of Go, Kafka (KRaft), and Kubernetes**, and how to build a **simple, scalable data pipeline** step by step.

---

## Step 1: Understanding Data Pipelines

A **data pipeline** is a set of processes that ingest, process, transform, and store data efficiently. Common components include:

1. **Data Ingestion** – Collecting raw data from different sources.
2. **Processing & Transformation** – Cleaning, filtering, and processing data.
3. **Storage** – Saving processed data in databases or cloud storage.
4. **Serving & Visualization** – Making data available for analytics, dashboards, or other applications.

Modern data pipelines should be **scalable, resilient, and fault-tolerant**—which is where **Go, Kafka (KRaft mode), MongoDB, and Kubernetes** come into play.

---

## Step 2: Setting Up the Local Kubernetes Cluster (Minikube)

For this demo, we'll use **Minikube**, a local Kubernetes cluster.

### 1. Install Minikube
> Check out minikube installation guides for all platforms at: [minikube installation guides](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download)

```sh
# Install Minikube (WSL Ubuntu 22.04)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
Verify installation:

```sh
minikube version
```
sample output
```sh
minikube version: v1.36.0
```

### 2. Start Minikube Cluster

```sh
minikube start --cpus=4 --memory=8192 --kubernetes-version=v1.33.1
```

sample output
```sh
😄  minikube v1.36.0 on Ubuntu 22.04 (amd64)
✨  Using the docker driver based on existing profile
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.47 ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.33.1 on Docker 28.1.1 ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```


Verify installation:

```sh
kubectl get nodes
```

sample output:
```sh

NAME       STATUS   ROLES           AGE     VERSION
minikube   Ready    control-plane   9m42s   v1.33.1
```

---

## Step 3: Building a Dummy Data Generator

We need an application to **continuously push large amounts of dummy data to a Kafka topic**.

### 1. Create a Go-based Kafka Producer

```go
package main

import (
    "fmt"
    "log"
    "time"
    "github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
    p, err := kafka.NewProducer(&kafka.ConfigMap{"bootstrap.servers": "kafka.default.svc.cluster.local:9092"})
    if err != nil {
        log.Fatalf("Failed to create producer: %s", err)
    }
    defer p.Close()

    topic := "dummy-data"
    for {
        message := fmt.Sprintf("{\"timestamp\": \"%s\", \"value\": %d}", time.Now().Format(time.RFC3339), time.Now().UnixNano())
        err := p.Produce(&kafka.Message{TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny}, Value: []byte(message)}, nil)
        if err != nil {
            log.Printf("Failed to produce message: %s", err)
        }
        time.Sleep(100 * time.Millisecond) // Adjust load rate
    }
}
```

Build and deploy this **Kafka producer** in a Kubernetes **Deployment**.

---

## Step 4: Deploying a Kafka Cluster in KRaft Mode on Kubernetes

### Create a Namespace for Kafka
```sh
kubectl create namespace kafka
```
sample output
```sh
namespace/kafka created
```

We’ll use **Bitnami’s Kafka Helm chart** to deploy a Zookeeper-free Kafka cluster using **KRaft mode**.

### 1. Add Bitnami Helm Repository

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 2. Install Kafka in KRaft Mode
- We shall install Bitnami Kafka Helm Chart with KRaft Mode (Bitnami supports Kafka KRaft mode via Helm).

```sh
 helm repo add bitnami https://charts.bitnami.com/bitnami
```

sample output:
```sh
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/rahulspa/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/rahulspa/.kube/config
"bitnami" has been added to your repositories
```

```sh
helm repo update
```
sample output:
```sh
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/rahulspa/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/rahulspa/.kube/config
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
```
- Create a `k8s/kraft-values.yaml` file for KRaft mode

```yaml

# kraft-values.yaml
controller:
  replicaCount: 3

kafka:
  kraft:
    enabled: true
    clusterId: "my-cluster-id"  # Must be fixed across upgrades
  replicas: 3
  listeners:
    client:
      protocol: PLAINTEXT
  configurationOverrides:
    "log.retention.hours": 168
    "log.segment.bytes": 1073741824
    "log.retention.check.interval.ms": 300000

```
- Install kafka cluster

```sh
helm install kafka bitnami/kafka -n kafka -f k8s/kraft-values.yaml
```
sample output:
```sh

WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/rahulspa/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/rahulspa/.kube/config
NAME: kafka
LAST DEPLOYED: Wed Jun  4 12:22:58 2025
NAMESPACE: kafka
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: kafka
CHART VERSION: 32.2.12
APP VERSION: 4.0.0

Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami for more information.

** Please be patient while the chart is being deployed **

Kafka can be accessed by consumers via port 9092 on the following DNS name from within your cluster:

    kafka.kafka.svc.cluster.local

Each Kafka broker can be accessed by producers via port 9092 on the following DNS name(s) from within your cluster:

    kafka-controller-0.kafka-controller-headless.kafka.svc.cluster.local:9092
    kafka-controller-1.kafka-controller-headless.kafka.svc.cluster.local:9092
    kafka-controller-2.kafka-controller-headless.kafka.svc.cluster.local:9092

The CLIENT listener for Kafka client connections from within your cluster have been configured with the following security settings:
    - SASL authentication

To connect a client to your Kafka, you need to create the 'client.properties' configuration files with the content below:

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-256
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="user1" \
    password="$(kubectl get secret kafka-user-passwords --namespace kafka -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d , -f 1)";

To create a pod that you can use as a Kafka client run the following commands:

    kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:4.0.0-debian-12-r7 --namespace kafka --command -- sleep infinity
    kubectl cp --namespace kafka /path/to/client.properties kafka-client:/tmp/client.properties
    kubectl exec --tty -i kafka-client --namespace kafka -- bash

    PRODUCER:
        kafka-console-producer.sh \
            --producer.config /tmp/client.properties \
            --bootstrap-server kafka.kafka.svc.cluster.local:9092 \
            --topic test

    CONSUMER:
        kafka-console-consumer.sh \
            --consumer.config /tmp/client.properties \
            --bootstrap-server kafka.kafka.svc.cluster.local:9092 \
            --topic test \
            --from-beginning

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - controller.resources
  - defaultInitContainers.prepareConfig.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
```
This will deploy:
- 3 Kafka brokers with KRaft controller enabled
- No need for Zookeeper

- Verify Pods and Services
```sh
kubectl get pods -n kafka
```
sample output:
```sh
NAME                 READY   STATUS    RESTARTS   AGE
kafka-controller-0   1/1     Running   0          4m
kafka-controller-1   1/1     Running   0          4m
kafka-controller-2   1/1     Running   0          4m
```

```sh
kubectl get svc -n kafka
```
sample output:
```sh
NAME                        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE
kafka                       ClusterIP   10.108.84.2   <none>        9092/TCP                     6m13s
kafka-controller-headless   ClusterIP   None          <none>        9094/TCP,9092/TCP,9093/TCP   6m13s
```

### 3. Test Kafka Cluster

---

## Step 5: Building an ETL Application in Golang

The **ETL (Extract, Transform, Load) Application** will:

* Extract data from Kafka.
* Transform data into an upsert format.
* Load data into MongoDB.

### 1. Go-based Kafka Consumer & MongoDB Upserter

```go
package main

import (
    "context"
    "log"
    "time"
    "github.com/confluentinc/confluent-kafka-go/kafka"
    "go.mongodb.org/mongo-driver/bson"
    "go.mongodb.org/mongo-driver/mongo"
    "go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
    consumer, _ := kafka.NewConsumer(&kafka.ConfigMap{"bootstrap.servers": "kafka.default.svc.cluster.local:9092", "group.id": "etl-group", "auto.offset.reset": "earliest"})
    consumer.Subscribe("dummy-data", nil)

    client, _ := mongo.Connect(context.TODO(), options.Client().ApplyURI("mongodb://mongo-service:27017"))
    collection := client.Database("etl_db").Collection("data")

    for {
        msg, err := consumer.ReadMessage(-1)
        if err == nil {
            data := bson.M{"timestamp": time.Now(), "value": string(msg.Value)}
            _, err := collection.InsertOne(context.TODO(), data)
            if err != nil {
                log.Println("Insert error:", err)
            }
        }
    }
}
```

---

## Step 6: Deploying MongoDB on Kubernetes

Create `mongodb.yaml` manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo
        ports:
        - containerPort: 27017
```

Deploy MongoDB:

```sh
kubectl apply -f mongodb.yaml
```

---

## Step 7: Autoscaling the ETL Application

We will configure **Horizontal Pod Autoscaler (HPA)** to scale our ETL application based on Kafka load.

### Apply HPA Policy

```sh
kubectl autoscale deployment etl-app --cpu-percent=50 --min=1 --max=10
```

---

## Step 8: Benchmarking Performance

Use **k6** to simulate load:

```sh
k6 run load-test.js
```

Monitor Kafka consumer lag and MongoDB performance using **Prometheus & Grafana**.

---

## Conclusion

- ✅ **Fully automated Kafka-based data pipeline** in Go & Kubernetes (Zookeeper-free).
- ✅ **Auto-scaled ETL logic** ensures efficient performance.
- ✅ **Step-by-step deployment & benchmarking** for real-world readiness.

💡 **Next Steps**: Build advanced analytics, use cloud-native services, or optimize for large-scale production!

📌 **Full GitHub repository** coming soon!
