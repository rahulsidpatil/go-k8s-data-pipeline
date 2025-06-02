package main

import (
    "fmt"
    "time"
    "github.com/segmentio/kafka-go"
)

func main() {
    writer := kafka.NewWriter(kafka.WriterConfig{
        Brokers: []string{"kafka-service:9092"},
        Topic:   "etl-topic",
    })
    for {
        err := writer.WriteMessages(nil, kafka.Message{
            Value: []byte(fmt.Sprintf("message-%d", time.Now().Unix())),
        })
        if err != nil {
            fmt.Println("Write failed:", err)
        }
        time.Sleep(1 * time.Second)
    }
}
