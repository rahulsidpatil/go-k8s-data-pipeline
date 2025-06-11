
# ✅ HPA Validation Test for Go-K8s Data Pipeline

This guide helps validate that Horizontal Pod Autoscaler (HPA) works correctly for the `etl-consumer` deployment in your local Minikube cluster.

---

## 🛠 Prerequisites

Ensure Minikube and the Kubernetes cluster are running:

```bash
minikube status
kubectl get nodes
kubectl get pods -A
```

Ensure Metrics Server is enabled:

```bash
kubectl get deployment metrics-server -n kube-system
```

If not found:

```bash
minikube addons enable metrics-server
```

---

## ⚙️ Verify `etl-consumer` Deployment and HPA

### Check CPU resource requests and limits:

Make sure the `k8s/consumer-deployment.yaml` has:

```yaml
resources:
  requests:
    cpu: "100m"
  limits:
    cpu: "300m"
```

### Sample HPA YAML (`etl-consumer-hpa.yaml`):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: etl-consumer-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: etl-consumer
  minReplicas: 1
  maxReplicas: 3
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

Apply the HPA:

```bash
kubectl apply -f k8s/consumer-deployment.yaml
kubectl apply -f k8s/etl-consumer-hpa.yaml
```

---

## 🔁 Step-by-Step Load Test

### Step 1: Start with 1 dummy producer pod

```bash
kubectl scale deployment dummy-producer --replicas=1
watch kubectl get pods
```

---

### Step 2: Generate load with more producer pods

```bash
kubectl scale deployment dummy-producer --replicas=5
```

---

### Step 3: Watch HPA behavior

```bash
kubectl get hpa etl-consumer-hpa -w
```

Expected: CPU usage increases, and HPA scales up the number of `etl-consumer` pods (up to 3).

---

### Step 4: Reduce load

```bash
kubectl scale deployment dummy-producer --replicas=1
```

After a few minutes of low CPU, HPA should reduce `etl-consumer` pods.

---

### Step 5: Final report

```bash
kubectl describe hpa etl-consumer-hpa
```

This shows current CPU usage, desired pods, and event history.

---

## ✅ Summary Table

| Step | Action | Expected Result |
|------|--------|------------------|
| 1 | Deploy 1 producer pod | Steady CPU on `etl-consumer` |
| 2 | Scale to 5 producer pods | HPA scales `etl-consumer` up |
| 3 | Scale down to 1 producer | HPA scales `etl-consumer` down |
| 4 | Observe HPA | CPU metrics reflect load |
| 5 | Describe HPA | Shows scaling decisions |

---
