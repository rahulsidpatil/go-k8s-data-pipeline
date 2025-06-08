NAMESPACE=kafka

install:
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -f k8s/mongodb.yaml

uninstall:
	kubectl delete -f k8s/mongodb.yaml

test:
	@echo "🔍 Verifying MongoDB Pod..."
	kubectl get pods -n kafka | grep mongodb || true
	kubectl wait --for=condition=Ready pod/mongodb-0 -n $(NAMESPACE) --timeout=120s
	sleep 5 # Wait for MongoDB to be ready
	@echo "\n🔍 Checking MongoDB connection..."
	kubectl exec -n kafka mongodb-0 -- mongosh --eval "db.runCommand({ connectionStatus: 1 })"

init-db:
	@echo "🍃 Creating initial MongoDB database and collection..."
	kubectl cp init-db.js kafka/mongodb-0:/tmp/init-db.js -c mongodb
	kubectl exec -n kafka mongodb-0 -c mongodb -- \
		mongosh "mongodb://admin:password@localhost:27017/admin" /tmp/init-db.js



