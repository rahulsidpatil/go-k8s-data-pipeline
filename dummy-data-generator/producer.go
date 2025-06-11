package main

import (
	"context"
	"encoding/json"
	"log"
	"math/rand"
	"os"
	"strconv"
	"time"

	kafka "github.com/segmentio/kafka-go"
)

type Event struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Timestamp time.Time `json:"timestamp"`
}

func generateDummyEvent(id int) Event {
	names := []string{"alpha", "beta", "gamma", "delta"}
	return Event{
		ID:        time.Now().Nanosecond(),
		Name:      names[rand.Intn(len(names))],
		Timestamp: time.Now(),
	}
}

func main() {
	sleepInterval := 5000 // default to 5000 milliseconds
	if val, ok := os.LookupEnv("SLEEP_INTERVAL_MS"); ok {
		if parsed, err := strconv.Atoi(val); err == nil && parsed > 0 {
			sleepInterval = parsed
		} else {
			log.Printf("Invalid SLEEP_INTERVAL_MS value, using default: %d ms", sleepInterval)
		}
	}

	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  []string{"kafka:9092"},
		Topic:    "test-topic",
		Balancer: &kafka.LeastBytes{},
	})
	defer writer.Close()

	var i int
	for {
		i++
		event := generateDummyEvent(i)
		data, _ := json.Marshal(event)
		err := writer.WriteMessages(context.Background(),
			kafka.Message{
				Key:   []byte(string(rune(i))),
				Value: data,
			},
		)
		if err != nil {
			log.Printf("failed to write message: %v", err)
		} else {
			log.Printf("produced message: %s", string(data))
		}
		time.Sleep(time.Duration(sleepInterval) * time.Millisecond)
	}
}
