package main

import (
	"context"
	"encoding/json"
	"log"

	kafka "github.com/segmentio/kafka-go"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type RawKafkaMessage struct {
    ID        int    `json:"id"`
    Name      string `json:"name"`
    Timestamp string `json:"timestamp"`
}

func main() {
    ctx := context.Background()

    kafkaReader := kafka.NewReader(kafka.ReaderConfig{
        Brokers:   []string{"kafka:9092"},
        Topic:     "test-topic",
        Partition: 0,
        MinBytes:  1,
        MaxBytes:  10e6,
    })
    defer kafkaReader.Close()

    mongoURI := "mongodb://etluser:etlp%40ss123@mongodb-0.mongodb.kafka.svc.cluster.local:27017/etl_db"
    mongoClient, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoURI))
    if err != nil {
        log.Fatalf("Mongo connection error: %v", err)
    }
    defer mongoClient.Disconnect(ctx)

    collection := mongoClient.Database("etl_db").Collection("messages")

    for {
        m, err := kafkaReader.ReadMessage(ctx)
        if err != nil {
            log.Printf("Kafka read error: %v", err)
            continue
        }
        log.Printf("Received message: %s", string(m.Value))

        var msg RawKafkaMessage
        if err := json.Unmarshal(m.Value, &msg); err != nil {
            log.Printf("Unmarshal error: %v", err)
            continue
        }

        _, err = collection.InsertOne(ctx, msg)
        if err != nil {
            log.Printf("Insert error: %v", err)
        } else {
            log.Println("Inserted message into MongoDB")
        }
    }
}
