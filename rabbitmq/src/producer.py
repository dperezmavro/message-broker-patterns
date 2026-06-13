# producer.py - Sends messages to RabbitMQ
import json
import os
import random
import time

import pika
from dotenv import load_dotenv

from parameters import get_params


def publish_message(
    channel: pika.adapters.blocking_connection.BlockingChannel,
    id: str,
    message_data: any,
):
    channel.basic_publish(
        exchange=os.getenv("RMQ_EXCHANGE"),
        routing_key=os.getenv("RMQ_ROUTING_KEY"),
        body=json.dumps(message_data),
        properties=pika.BasicProperties(
            delivery_mode=pika.DeliveryMode.Persistent,
            content_type="application/json",
            message_id=id,
        ),
    )
    print(f"Sent: {message_data}")


def main():
    load_dotenv(".env.producer")

    connection = pika.BlockingConnection(get_params())
    channel = connection.channel()

    while True:
        id = (random.randint(1, 100),)
        publish_message(
            channel,
            f"{id}",
            {
                "task_id": f"{id}",
                "action": "process_data",
                "timestamp": time.time(),
            },
        )
        time.sleep(0.5)

    connection.close()


if __name__ == "__main__":
    main()
