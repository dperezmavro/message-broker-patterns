# producer.py - Sends messages to RabbitMQ
import pika
import json
import time
from dotenv import load_dotenv
import os
import random
from parameters import parameters as params


def publish_message(channel: pika.adapters.blocking_connection.BlockingChannel, id: int, message_data):
    """
    Publish a message to the task queue.
    Messages are persisted to disk for durability.
    """
    channel.basic_publish(
        exchange=os.getenv("RMQ_EXCHANGE"),
        routing_key=os.getenv("RMQ_ROUTING_KEY"),  # Queue name
        body=json.dumps(message_data),
        properties=pika.BasicProperties(
            delivery_mode=2,  # Make message persistent
            content_type="application/json",
            message_id=str(id),
        ),
    )
    print(f"Sent: {message_data}")


def main():
    load_dotenv()

    
    # Establish connection to RabbitMQ
    connection = pika.BlockingConnection(params)
    channel = connection.channel()

    # Declare a durable queue (survives broker restart)
    # durable=True persists the queue definition
    channel.queue_declare(
        queue=os.getenv("RMQ_VHOST"),
        durable=True,
    )

    # Send sample messages
    while True:
        id = (random.randint(1, 100),)
        publish_message(
            channel,
            id,
            {
                "task_id": id,
                "action": "process_data",
                "timestamp": time.time(),
            },
        )
        print("[*] Sleeping...")
        time.sleep(1)

    # Clean up connection
    connection.close()


if __name__ == "__main__":
    main()
