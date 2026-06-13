from dotenv import load_dotenv
import json
import os
import pika
import time
import random


class RabbitMQBase:
    def __init__(self, dotenv_file: str):
        load_dotenv(dotenv_file)

        self.credentials = pika.PlainCredentials(
            os.getenv("RMQ_USER"),
            os.getenv("RMQ_PASS"),
        )

        self.connection_params = pika.ConnectionParameters(
            host=os.getenv("RMQ_HOST"),
            port=int(os.getenv("RMQ_PORT")),
            virtual_host=os.getenv("RMQ_VHOST"),
            credentials=self.credentials,
            heartbeat=10,
            connection_attempts=3,
            retry_delay=5,
        )


class Consumer(RabbitMQBase):
    def __init__(self, dotenv_file: str | None = ".env.consumer"):
        super().__init__(dotenv_file)
        self.queue_name = os.getenv("RMQ_QUEUE")
        self.connection = pika.BlockingConnection(self.connection_params)
        self.channel = self.connection.channel()

        self.channel.basic_qos(prefetch_count=1)

    def process_message(self, ch, method, properties, body):
        try:
            message = json.loads(body)
            print(f"[*] Processing task {message['task_id']}")

            # Simulate work
            time.sleep(1)

            ch.basic_ack(delivery_tag=method.delivery_tag)
            print(f"--Completed task {message['task_id']}")

        except Exception as e:
            print(f"Error processing message: {e}")
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

    def basic_consume(self):
        self.channel.basic_consume(
            queue=self.queue_name,
            on_message_callback=self.process_message,
            auto_ack=False,
        )

        print("Waiting for messages. Press CTRL+C to exit.")
        self.channel.start_consuming()


class Producer(RabbitMQBase):
    def __init__(self, dotenv_file: str | None = ".env.producer"):
        super().__init__(dotenv_file)

        self.connection = pika.BlockingConnection(self.connection_params)
        self.channel = self.connection.channel()

    def publish(self):
        id = random.randint(1, 100)

        message_data = {
            "task_id": f"{id}",
            "action": "process_data",
            "timestamp": time.time(),
        }

        self.channel.basic_publish(
            exchange=os.getenv("RMQ_EXCHANGE"),
            routing_key=os.getenv("RMQ_ROUTING_KEY"),
            body=json.dumps(message_data),
            properties=pika.BasicProperties(
                delivery_mode=pika.DeliveryMode.Persistent,
                content_type="application/json",
                message_id=f"{id}",
            ),
        )
        print(f"Sent: {message_data}")

    def close_connection(self):
        self.connection.close()
