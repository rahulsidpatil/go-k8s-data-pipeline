# Helm/K8s config
RELEASE_NAME=kafka
NAMESPACE=kafka
CHART_REPO=bitnami/kafka
VALUES_FILE=kraft-values.yaml
TOPIC=test-topic
TEST_CLIENT_IMG := kafka-test-client:latest
TEST_CLIENT_NAME := kafka-test-client


# 🧹 Uninstall Kafka cluster and namespace
uninstall-kafka-cluster:
	helm uninstall $(RELEASE_NAME) -n $(NAMESPACE) || true
	kubectl delete pvc --all -n $(NAMESPACE)
	kubectl delete namespace $(NAMESPACE) || true

# 🚀 Install Kafka cluster
install-kafka-cluster:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	helm install $(RELEASE_NAME) $(CHART_REPO) -n $(NAMESPACE) -f $(VALUES_FILE)

# 🌐 Expose Kafka externally (NodePort)
expose:
	kubectl patch svc $(RELEASE_NAME) -n $(NAMESPACE) -p '{"spec": {"type": "NodePort"}}'
	kubectl get svc $(RELEASE_NAME) -n $(NAMESPACE)

# 🔁 Reinstall Kafka
reinstall-kafka-cluster: uninstall-kafka-cluster install-kafka-cluster

build-kafka-test-client:
	@echo "🔨 Building kafka-test-client image..."
	docker build -t $(TEST_CLIENT_IMG) -f Dockerfile.kafka-test-client . || (echo "❌ Build failed!" && exit 1)
	@echo "📦 Loading image into Minikube..."
	minikube image load $(TEST_CLIENT_IMG)

delete-kafka-test-client:
	kubectl delete pod $(TEST_CLIENT_NAME) -n $(NAMESPACE) --ignore-not-found

deploy-kafka-test-client:
	kubectl get namespace $(NAMESPACE) || kubectl create namespace $(NAMESPACE)
	@echo "🚀 Deploying custom Kafka test client..."
	kubectl delete pod kafka-test-client -n kafka --ignore-not-found
	kubectl run kafka-test-client \
		--restart='Never' \
		--image=kafka-test-client:latest \
		--namespace kafka \
		--image-pull-policy=IfNotPresent \
		--command -- bash -c "sleep 3600"

# ✅ Test Kafka cluster: status + produce + consume
test:
	@echo "🔍 Checking Kafka Pods..."
	kubectl get pods -n $(NAMESPACE) | grep kafka-controller
	kubectl wait --for=condition=Ready pod/kafka-controller-0 -n $(NAMESPACE) --timeout=120s

	@echo "\n🧼 Cleaning up any existing test pod..."
	kubectl delete pod kafka-test-client -n $(NAMESPACE) --ignore-not-found
	
	@echo "\n🚀 Deploying test client pod..."
	kubectl run kafka-test-client \
		--restart='Never' \
		--image=kafka-test-client:latest \
		--namespace kafka \
		--image-pull-policy=IfNotPresent \
		--command -- bash -c "sleep 3600"

	@echo "⏳ Waiting for pod to be ready..."
	kubectl wait --for=condition=Ready pod/kafka-test-client -n $(NAMESPACE) --timeout=60s

	@echo "\n📦 Creating topic: $(TOPIC)"
	kubectl exec -n $(NAMESPACE) kafka-test-client -- \
		kafka-topics.sh --bootstrap-server $(RELEASE_NAME):9092 --create --topic $(TOPIC) --partitions 1 --replication-factor 1 || true

	@echo "\n📨 Producing message..."
	kubectl exec -n $(NAMESPACE) kafka-test-client -- \
		sh -c "echo 'hello-k8s-kafka' | kafka-console-producer.sh --broker-list $(RELEASE_NAME):9092 --topic $(TOPIC)"

	@echo "\n📩 Consuming message..."
	kubectl exec -n $(NAMESPACE) kafka-test-client -- \
		kafka-console-consumer.sh --bootstrap-server $(RELEASE_NAME):9092 --topic $(TOPIC) --from-beginning --max-messages 1

	@echo "\n🧼 Cleaning up test client..."
	kubectl delete pod kafka-test-client -n $(NAMESPACE)

.PHONY: uninstall-kafka-cluster install-kafka-cluster expose test reinstall-kafka-cluster

# ✅ Test Kafka cluster status
test-kafka-cluster:
	kubectl -n $(NAMESPACE) get pods
	kubectl exec -n $(NAMESPACE) kafka-test-client -- bash -c "kafka-topics.sh --bootstrap-server kafka-controller-0.kafka-controller-headless.kafka.svc.cluster.local:9092 --list"

# 🧵 Create topic if not exists
create-kafka-topic:
	kubectl exec -n $(NAMESPACE) kafka-test-client -- bash -c "kafka-topics.sh --bootstrap-server kafka-controller-0.kafka-controller-headless.kafka.svc.cluster.local:9092 --create --topic $(TOPIC) --partitions 1 --replication-factor 1 --if-not-exists"

# 📨 Produce test message
produce-kafka-message:
	kubectl exec -n $(NAMESPACE) -i kafka-test-client -- bash -c "echo 'hello-kafka' | kafka-console-producer.sh --bootstrap-server kafka-controller-0.kafka-controller-headless.kafka.svc.cluster.local:9092 --topic $(TOPIC)"

# 📩 Consume messages from topic
consume-kafka-message:
	kubectl exec -n $(NAMESPACE) kafka-test-client -- bash -c "kafka-console-consumer.sh --bootstrap-server kafka-controller-0.kafka-controller-headless.kafka.svc.cluster.local:9092 --topic $(TOPIC) --from-beginning --timeout-ms 5000"