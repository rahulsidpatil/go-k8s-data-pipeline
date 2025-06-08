IMAGE_NAME=dummy-producer:latest
NAMESPACE=kafka

build:
	docker build -t $(IMAGE_NAME) .
	@echo "🔨 Building dummy-data-producer image..."
	docker build -t $(IMAGE_NAME) . || (echo "❌ Build failed!" && exit 1)
	@echo "📦 Loading image into Minikube..."
	minikube image load $(IMAGE_NAME)

deploy:
	kubectl apply -f k8s/StatefulSet.yaml
	kubectl apply -f k8s/service.yaml || true

verify:
	@echo "🔍 Verifying Dummy Data Producer Pod..."
	kubectl get pods -n $(NAMESPACE) | grep dummy-producer || true
	kubectl wait --for=condition=Ready pod/dummy-producer-0 -n $(NAMESPACE) --timeout=120s
	sleep 5 # Wait for the dummy data producer to be ready
	@echo "\n🔍 Checking Dummy Data Producer logs..."
	kubectl logs -l app=dummy-producer -n $(NAMESPACE) --tail=10

verify-kafka-connection:
	@echo "🔍 Verifying Kafka connection..."
	kubectl exec -n $(NAMESPACE) dummy-producer-0 -c kafka-cli -- \
		kafka-console-producer.sh --broker-list kafka:9092 --topic test-topic --producer-property acks=all || true
	kubectl exec -n $(NAMESPACE) dummy-producer-0 -c kafka-cli -- \
		kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic test-topic --from-beginning --max-messages 1 || true


install: build deploy verify verify-kafka-connection

uninstall:
	kubectl delete -f k8s/StatefulSet.yaml || true
	kubectl delete -f k8s/service.yaml || true

logs:
	kubectl logs -l app=dummy-producer -n $(NAMESPACE) -f

describe:
	kubectl describe pod -l app=dummy-producer -n $(NAMESPACE)