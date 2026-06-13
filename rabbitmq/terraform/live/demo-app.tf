locals {
  events_exchange_name = "${var.vhost_name}.events"
  dlx_exchange_name    = "${var.vhost_name}.dlx"

  task_processor_queue_name  = "${var.vhost_name}.task-processor"
  task_processor_routing_key = "task.process_data"

  producer_username = "svc.producer.${var.vhost_name}"
  consumer_username = "svc.consumer.${var.vhost_name}"
}

resource "rabbitmq_vhost" "demo_app" {
  name = var.vhost_name
}

module "producer_user" {
  source = "../modules/vhost_user"

  name     = local.producer_username
  password = "producer"
  vhost    = rabbitmq_vhost.demo_app.name
}

module "consumer_user" {
  source = "../modules/vhost_user"

  name     = local.consumer_username
  password = "consumer"
  vhost    = rabbitmq_vhost.demo_app.name
}

# Application events exchange. Topic so routing keys like task.process_data
# can fan out per event type.
resource "rabbitmq_exchange" "events" {
  name  = local.events_exchange_name
  vhost = rabbitmq_vhost.demo_app.name

  settings {
    type        = "topic"
    durable     = false
    auto_delete = false
  }
}

# Shared dead-letter exchange. Direct so each queue's DLQ is routed by its own key.
resource "rabbitmq_exchange" "dlx" {
  name  = local.dlx_exchange_name
  vhost = rabbitmq_vhost.demo_app.name

  settings {
    type        = "direct"
    durable     = true
    auto_delete = false
  }
}

module "task_processor_queue" {
  source = "../modules/queue_with_dlq"

  name                 = local.task_processor_queue_name
  vhost                = rabbitmq_vhost.demo_app.name
  main_source_exchange = rabbitmq_exchange.events.name
  main_routing_key     = local.task_processor_routing_key
  dlq_source_exchange  = rabbitmq_exchange.dlx.name

  dlq_message_ttl_ms = 7 * 24 * 60 * 60 * 1000 # 7 days
  dlq_max_length     = 100000
}
