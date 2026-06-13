variable "name" {
  description = "Base name for the main queue. The DLQ is named {var.name}-dlq\"."
  type        = string
}

variable "vhost" {
  description = "RabbitMQ vhost the queue and DLQ live in."
  type        = string
}

variable "source_exchange" {
  description = "Exchange that feeds the main queue."
  type        = string
}

variable "routing_key" {
  description = "Routing key used to bind the main queue to source_exchange. Ignored by fanout exchanges but still required for the binding."
  type        = string
}

variable "dlx_exchange" {
  description = "Name of the shared DLX exchange. Set as x-dead-letter-exchange on the main queue and used as the source for the DLQ binding."
  type        = string
}

variable "delivery_limit" {
  description = "Max redeliveries before a quorum queue dead-letters a message."
  type        = number
  default     = 10
}

variable "queue_type" {
  description = "Main queue type. Must support x-delivery-limit if you rely on poison-message dead-lettering."
  type        = string
  default     = "quorum"
}

variable "dlq_message_ttl_ms" {
  description = "TTL on DLQ messages in ms. Null disables."
  type        = number
  default     = null
}

variable "dlq_max_length" {
  description = "Max messages held in the DLQ. Null disables."
  type        = number
  default     = null
}
