#!/bin/bash

echo "Start time: $(date)"
start=$(date +%s)

kubectl logs -l app=etl-consumer -n default --tail=100 > logs.txt

end=$(date +%s)
duration=$((end - start))

echo "Processed messages in: $duration seconds"
grep -c "Consumed" logs.txt
