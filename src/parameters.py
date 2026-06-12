import pika
import os
from dotenv import load_dotenv



load_dotenv()



def get_params(producer: bool = False):
    credentials = pika.PlainCredentials(
        os.getenv("RMQ_USER_CONSUMER"),
        os.getenv("RMQ_PASS_CONSUMER"),
    )    
    if producer:
        # Connection parameters (same as producer)
        credentials = pika.PlainCredentials(
            os.getenv("RMQ_USER_PRODUCER"),
            os.getenv("RMQ_PASS_PRODUCER"),
        )
    

    parameters = pika.ConnectionParameters(
        host=os.getenv("RMQ_HOST"),
        port=int(os.getenv("RMQ_PORT")),
        virtual_host=os.getenv("RMQ_VHOST"),
        credentials=credentials,
        # Heartbeat keeps connection alive
        heartbeat=60,
        # Retry connection on failure
        connection_attempts=3,
        retry_delay=5,
    )

    return parameters