# producer.py - Sends messages to RabbitMQ
import time
from rabbit_mq_base import Producer

def main():
    p = Producer()
    while True:
        p.publish()
        time.sleep(0.5)

    
if __name__ == "__main__":
    main()
