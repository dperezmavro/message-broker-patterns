# Create a virtual host
resource "rabbitmq_vhost" "application" {
  name = var.name
}

resource "rabbitmq_user" "producer" {
  name     = "producer"
  password = "producer"
}

resource "rabbitmq_permissions" "producer" {
  user  = rabbitmq_user.producer.name
  vhost = rabbitmq_vhost.application.name

  permissions {
    configure = ".*"
    write     = ".*"
    read      = ".*"
  }
}

resource "rabbitmq_user" "consumer" {
  name     = "consumer"
  password = "consumer"
}

resource "rabbitmq_permissions" "consumer" {
  user  = rabbitmq_user.consumer.name
  vhost = rabbitmq_vhost.application.name

  permissions {
    configure = ".*"
    write     = ".*"
    read      = ".*"
  }
}

resource "rabbitmq_exchange" "exchange" {
  name  = var.name
  vhost = rabbitmq_vhost.application.name

  settings {
    type        = "fanout"
    durable     = false
    auto_delete = false
  }
}

resource "rabbitmq_queue" "queue" {
  name  = var.name
  vhost = rabbitmq_vhost.application.name

  settings {
    durable     = true
    auto_delete = false
    arguments_json = jsonencode({
      # "x-message-ttl" : 3600,
      "x-dead-letter-exchange" : "dlx",
      "x-dead-letter-routing-key" : "${var.name}-dlx"
      "x-delivery-limit": 10,
      "x-queue-type" : "quorum",
    })
  }
}

resource "rabbitmq_binding" "binding" {
  source           = rabbitmq_exchange.exchange.name
  vhost            = rabbitmq_vhost.application.name
  destination      = rabbitmq_queue.queue.name
  destination_type = "queue"
  routing_key      = "demo-app-producer-tasks"
}
