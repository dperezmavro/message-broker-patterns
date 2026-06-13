import os
import pika


def get_params() -> pika.ConnectionParameters:
    credentials = pika.PlainCredentials(
        os.getenv("RMQ_USER"),
        os.getenv("RMQ_PASS"),
    )

    return pika.ConnectionParameters(
        host=os.getenv("RMQ_HOST"),
        port=int(os.getenv("RMQ_PORT")),
        virtual_host=os.getenv("RMQ_VHOST"),
        credentials=credentials,
        heartbeat=10,
        connection_attempts=3,
        retry_delay=5,
    )
