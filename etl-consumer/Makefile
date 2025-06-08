IMAGE_NAME=etl-consumer:latest
NAMESPACE=kafka
.PHONY: build-etl load-etl deploy-etl verify-etl

etl-build:
	docker build -t $(IMAGE_NAME) .
	@echo "🔨 Building dummy-data-producer image..."
	docker build -t $(IMAGE_NAME) . || (echo "❌ Build failed!" && exit 1)
	@echo "📦 Loading image into Minikube..."
	minikube image load $(IMAGE_NAME)

etl-load:
	minikube image load $(IMAGE_NAME)

etl-deploy:
	kubectl apply -f k8s/mongo-secret.yaml
	kubectl apply -f k8s/statefulset.yaml
	kubectl apply -f k8s/hpa.yaml


etl-verify-kafka-connection:
	@echo "🔍 Verifying Kafka connection..."
	kubectl exec -n $(NAMESPACE) etl-consumer-0 -c kafka-cli -- \
	  kafka-console-producer.sh --broker-list kafka:9092 --topic test-topic --producer-property acks=all || true
	kubectl exec -n $(NAMESPACE) etl-consumer-0 -c kafka-cli -- \
	  kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic test-topic --from-beginning --max-messages 1 || true

etl-verify-mongo-connection:
	@echo "🔍 Verifying MongoDB connection..."
	kubectl exec -n $(NAMESPACE) etl-consumer-0 -c mongo-cli -- \
	  mongosh mongodb://mongodb-0.mongodb.kafka.svc.cluster.local:27017/etl_db --eval 'db.runCommand({ connectionStatus: 1 })'

etl-show-messages:
	@echo "🔍 Displaying messages from MongoDB..."
	kubectl exec -n kafka mongodb-0 -c mongodb -- \
	mongosh "mongodb://admin:password@localhost:27017/admin" --eval "db = db.getSiblingDB('etl_db'); printjson(db.messages.find().limit(5).toArray());"

etl-verify-status:
	@echo "🔍 Checking ETL consumer health..."
	kubectl get pods -n $(NAMESPACE) | grep etl-consumer || true
	kubectl wait --for=condition=Ready pod/etl-consumer-0 -n $(NAMESPACE) --timeout=120s

etl-install: etl-build etl-deploy

etl-verify: etl-verify-status etl-verify-kafka-connection etl-verify-mongo-connection etl-logs etl-show-messages

etl-uninstall:
	kubectl delete -f k8s/statefulset.yaml || true
	kubectl delete -f k8s/hpa.yaml || true

etl-logs:
	kubectl logs -n kafka -l app=etl-consumer --tail=50
