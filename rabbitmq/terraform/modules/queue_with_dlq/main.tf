terraform {
  required_providers {
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
    }
  }
}

locals {
  dlq_name        = "${var.name}-dlq"
  dlq_routing_key = "${var.name}-dlx"

  dlq_arguments = merge(
    { "x-queue-type" = "quorum" },
    var.dlq_message_ttl_ms == null ? {} : { "x-message-ttl" = var.dlq_message_ttl_ms },
    var.dlq_max_length == null ? {} : { "x-max-length" = var.dlq_max_length },
  )
}

resource "rabbitmq_queue" "main" {
  name  = var.name
  vhost = var.vhost

  settings {
    durable     = true
    auto_delete = false
    arguments_json = jsonencode({
      "x-queue-type"              = var.queue_type
      "x-delivery-limit"          = var.delivery_limit
      "x-dead-letter-exchange"    = var.dlx_exchange
      "x-dead-letter-routing-key" = local.dlq_routing_key
    })
  }
}

resource "rabbitmq_queue" "dlq" {
  name  = local.dlq_name
  vhost = var.vhost

  settings {
    durable        = true
    auto_delete    = false
    arguments_json = jsonencode(local.dlq_arguments)
  }
}

resource "rabbitmq_binding" "main" {
  source           = var.source_exchange
  vhost            = var.vhost
  destination      = rabbitmq_queue.main.name
  destination_type = "queue"
  routing_key      = var.routing_key
}

resource "rabbitmq_binding" "dlq" {
  source           = var.dlx_exchange
  vhost            = var.vhost
  destination      = rabbitmq_queue.dlq.name
  destination_type = "queue"
  routing_key      = local.dlq_routing_key
}
