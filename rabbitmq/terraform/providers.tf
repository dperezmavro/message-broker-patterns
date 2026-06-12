terraform {
  required_providers {
    rabbitmq = {
      source  = "cyrilgdn/rabbitmq"
      version = "1.10.1"
    }
  }
}

# Configure the RabbitMQ provider
provider "rabbitmq" {
  endpoint = "http://localhost:15672"
  username = "admin"
  password = "secretpassword123"
}

