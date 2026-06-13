from rabbit_mq_base import Consumer


def main():
    c = Consumer()
    c.basic_consume()


if __name__ == "__main__":
    main()
