.PHONY: all help install-go verify-go install-minikube verify-minikube start-minikube \
        kafka mongo dummy etl delete-kafka delete-mongo delete-dummy delete-etl clean \
        stop-minikube delete-minikube

all: help

help:
	@echo "Available targets:"
	@echo "  install-go            - Install Go programming language"
	@echo "  verify-go             - Verify Go installation"
	@echo "  install-minikube      - Install Minikube"
	@echo "  minikube-verify       - Verify Minikube installation"
	@echo "  minikube-dashboard    - Enable and access Minikube dashboard"
	@echo "  minikube-start        - Start Minikube with specified resources"
	@echo "  k8s-check             - Check Kubernetes cluster status"
	@echo "  stop-minikube         - Stop Minikube"
	@echo "  minikube-delete       - Delete Minikube cluster"
	@echo "  minikube-clean        - Stop and delete Minikube cluster"
	@echo "  kafka-install         - Install Kafka cluster"
	@echo "  kafka-verify          - Verify Kafka installation"
	@echo "  kafka-uninstall       - Uninstall Kafka cluster"
	@echo "  mongo-install         - Install MongoDB"
	@echo "  mongo-verify          - Verify MongoDB installation"
	@echo "  mongo-uninstall       - Uninstall MongoDB"
	@echo "  dummy-data-generator-install - Install Dummy Data Generator"
	@echo "  dummy-data-generator-verify - Verify Dummy Data Generator"
	@echo "  dummy-data-generator-uninstall - Uninstall Dummy Data Generator"
	@echo "  etl-consumer-install  - Install ETL Consumer"
	@echo "  etl-consumer-verify   - Verify ETL Consumer"
	@echo "  etl-consumer-uninstall - Uninstall ETL Consumer"
	@echo "  deploy-pipeline       - Deploy the entire pipeline (Minikube, Kafka, MongoDB, Dummy Data Generator, ETL Consumer)"
	@echo "  clean                 - Clean up all installed components"

install-go:
	sudo apt update && sudo apt install -y golang-go

verify-go:
	go version

install-minikube:
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
	sudo install minikube-linux-amd64 /usr/local/bin/minikube && \
	rm minikube-linux-amd64

minikube-verify:
	minikube version && \
	minikube status

minikube-dashboard:
	@echo "📦 Enabling Minikube dashboard..."
	minikube addons enable dashboard
	@echo "🌐 Access the dashboard at the following URL:"
	minikube dashboard --url

minikube-start:
	 minikube start --cpus=4 --memory=8192 --kubernetes-version=v1.33.1 --driver=docker
	 minikube-verify
	 minikube dashboard
	 k8s-check
	 
k8s-check:
	kubectl cluster-info && \
	kubectl get namespaces && \
	kubectl get services --all-namespaces && \
	# Check if the default namespace is available
	kubectl get namespace default && \
	# Check if the kube-system namespace is available
	kubectl get namespace kube-system && \
	# Check if the kube-public namespace is available
	kubectl get namespace kube-public && \
	# Check if the kube-node-lease namespace is available
	kubectl get namespace kube-node-lease && \
	# Check if the kube-scheduler namespace is available
	kubectl get namespace kube-scheduler && \
	# Check if the kube-controller-manager namespace is available
	kubectl get namespace kube-controller-manager && \
	# Check if the kube-proxy namespace is available
	kubectl get namespace kube-proxy && \
	# Check if the kube-dns namespace is available
	kubectl get namespace kube-dns && \
	# Check if the kube-storage namespace is available
	kubectl get namespace kube-storage && \
	kubectl get nodes	

stop-minikube:
	minikube stop

minikube-delete:
	minikube delete

minikube-clean:
	minikube stop && \
	minikube delete

kafka-install:
	$(MAKE) -C kafka-cluster install-kafka-cluster && \
	$(MAKE) -C kafka-cluster expose 

kafka-verify:
	$(MAKE) -C kafka-cluster test

kafka-uninstall:
	$(MAKE) -C kafka-cluster delete-kafka-test-client && \
	$(MAKE) -C kafka-cluster uninstall-kafka-cluster

mongo-install:
	$(MAKE) -C mongo-db install	&& \
	$(MAKE) -C mongo-db test

mongo-verify:
	$(MAKE) -C mongo-db test

mongo-uninstall:
	$(MAKE) -C mongo-db uninstall

dummy-data-generator-install:
	$(MAKE) -C dummy-data-generator install && \
	$(MAKE) -C dummy-data-generator verify	&& \
	$(MAKE) -C dummy-data-generator verify-kafka-connection

dummy-data-generator-verify:
	$(MAKE) -C dummy-data-generator verify	&& \
	$(MAKE) -C dummy-data-generator verify-kafka-connection

dummy-data-generator-uninstall:
	$(MAKE) -C dummy-data-generator uninstall

etl-consumer-install:
	$(MAKE) -C etl-consumer etl-install	&& \
	$(MAKE) -C etl-consumer etl-verify 

etl-consumer-verify:
	$(MAKE) -C etl-consumer etl-verify

etl-consumer-uninstall:
	$(MAKE) -C etl-consumer etl-uninstall

deploy-pipeline: minikube-start \
		kafka-install \
		mongo-install \
		dummy-data-generator-install \
		etl-consumer-install

clean: etl-consumer-uninstall \
	   dummy-data-generator-uninstall \
	   mongo-uninstall \
	   kafka-uninstall	\
	   minikube clean
