package main

import (
    "context"
    "fmt"
    "log"
    "github.com/segmentio/kafka-go"
)

func main() {
    reader := kafka.NewReader(kafka.ReaderConfig{
        Brokers: []string{"kafka-service:9092"},
        Topic:   "etl-topic",
        GroupID: "etl-consumer-group",
    })

    for {
        msg, err := reader.ReadMessage(context.Background())
        if err != nil {
            log.Println("Read error:", err)
            continue
        }
        fmt.Printf("Consumed: %s\n", msg.Value)
        // Save to MongoDB (skipped here)
    }
}
