# consumer.py - Receives and processes messages from RabbitMQ
import pika
import json
import time
import os
import dotenv

from parameters import get_params


def main():

    connection = pika.BlockingConnection(get_params(False))
    channel = connection.channel()

    # Process only one message at a time
    # Prevents fast consumer from grabbing all messages
    channel.basic_qos(prefetch_count=1)

    # Start consuming messages
    # auto_ack=False requires manual acknowledgment
    channel.basic_consume(
        queue=os.getenv("RMQ_QUEUE"),
        on_message_callback=process_message,
        auto_ack=False,
    )

    print("Waiting for messages. Press CTRL+C to exit.")
    channel.start_consuming()


def process_message(ch, method, properties, body):
    """
    Callback function to handle incoming messages.
    Acknowledges only after successful processing.
    """
    try:
        message = json.loads(body)
        print(f"Processing task {message['task_id']}")

        # Simulate work (replace with actual processing)
        time.sleep(1)

        # Acknowledge successful processing
        # Message is removed from queue only after ack
        ch.basic_ack(delivery_tag=method.delivery_tag)
        print(f"Completed task {message['task_id']}")

    except Exception as e:
        print(f"Error processing message: {e}")
        # Reject and requeue the message for retry
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)


if __name__ == "__main__":
    main()
