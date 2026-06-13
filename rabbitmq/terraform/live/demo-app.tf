resource "rabbitmq_vhost" "application" {
  name = var.name
}

module "producer" {
  source = "../modules/vhost_user"

  name     = "producer"
  password = "producer"
  vhost    = rabbitmq_vhost.application.name
}

module "consumer" {
  source = "../modules/vhost_user"

  name     = "consumer"
  password = "consumer"
  vhost    = rabbitmq_vhost.application.name
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

# Shared dead-letter exchange. Direct so each queue's DLQ can be routed by its own key.
resource "rabbitmq_exchange" "dlx" {
  name  = "dlx"
  vhost = rabbitmq_vhost.application.name

  settings {
    type        = "direct"
    durable     = true
    auto_delete = false
  }
}

module "demo_app_queue" {
  source = "../modules/queue_with_dlq"

  name            = var.name
  vhost           = rabbitmq_vhost.application.name
  source_exchange = rabbitmq_exchange.exchange.name
  routing_key     = "demo-app-producer-tasks"
  dlx_exchange    = rabbitmq_exchange.dlx.name

  dlq_message_ttl_ms = 7 * 24 * 60 * 60 * 1000 # 7 days
  dlq_max_length     = 100000
}
