#!/bin/bash

NAMESPACE="kafka"
DURATION_SEC=300
INTERVAL_SEC=10
LOG_FILE="benchmark-results.txt"
START_TIME=$(date +%s)

echo "🟢 Starting benchmark at $(date)" | tee $LOG_FILE

producer_pod=$(kubectl get pod -n $NAMESPACE -l app=dummy-producer -o jsonpath="{.items[0].metadata.name}")
consumer_pod=$(kubectl get pod -n $NAMESPACE -l app=etl-consumer -o jsonpath="{.items[0].metadata.name}")

echo "Producer Pod: $producer_pod" | tee -a $LOG_FILE
echo "Consumer Pod: $consumer_pod" | tee -a $LOG_FILE

# Use specific containers for logs
initial_produced=$(kubectl logs $producer_pod -n $NAMESPACE -c dummy-producer | grep "produced message" | wc -l)
initial_consumed=$(kubectl logs $consumer_pod -n $NAMESPACE -c etl-consumer  | grep "Inserted message into MongoDB" | wc -l)

echo "Initial messages produced: $initial_produced" | tee -a $LOG_FILE
echo "Initial messages consumed: $initial_consumed" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "Collecting CPU and Memory usage every ${INTERVAL_SEC}s for ${DURATION_SEC}s..." | tee -a $LOG_FILE

while [ $(($(date +%s) - $START_TIME)) -lt $DURATION_SEC ]; do
  echo "--- $(date) ---" | tee -a $LOG_FILE
  kubectl top pod -n $NAMESPACE | tee -a $LOG_FILE
  sleep $INTERVAL_SEC
done

sleep 5  # Allow some time for the last logs to be captured

total_produced=$(kubectl logs $producer_pod -n $NAMESPACE -c dummy-producer | grep "produced message" | wc -l)
echo "total_produced: $total_produced" 
total_consumed=$(kubectl logs $consumer_pod -n $NAMESPACE -c etl-consumer | grep "Inserted message into MongoDB" | wc -l)
echo "total_consumed: $total_consumed"

echo "" | tee -a $LOG_FILE
echo "📊 Benchmark Summary:" | tee -a $LOG_FILE
echo "Messages sent to Kafka: $((total_produced - initial_produced))" | tee -a $LOG_FILE
echo "Messages Inserted message into MongoDB: $((total_consumed - initial_consumed))" | tee -a $LOG_FILE
echo "Duration: ${DURATION_SEC}s" | tee -a $LOG_FILE
echo "Logs saved to $LOG_FILE" | tee -a $LOG_FILE
