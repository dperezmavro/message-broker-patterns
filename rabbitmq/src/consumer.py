# consumer.py - Receives and processes messages from RabbitMQ
import json
import os
import time

import pika
from dotenv import load_dotenv

from parameters import get_params


def main():
    load_dotenv(".env.consumer")

    connection = pika.BlockingConnection(get_params())
    channel = connection.channel()

    # Process only one message at a time
    channel.basic_qos(prefetch_count=1)

    channel.basic_consume(
        queue=os.getenv("RMQ_QUEUE"),
        on_message_callback=process_message,
        auto_ack=False,
    )

    print("Waiting for messages. Press CTRL+C to exit.")
    channel.start_consuming()


def process_message(ch, method, properties, body):
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


if __name__ == "__main__":
    main()
