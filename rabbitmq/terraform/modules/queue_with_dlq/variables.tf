variable "name" {
  description = "Fully-qualified main queue name. The DLQ defaults to \"{name}.dlq\"."
  type        = string
}

variable "vhost" {
  description = "RabbitMQ vhost the queue and DLQ live in."
  type        = string
}

variable "main_source_exchange" {
  description = "Exchange that feeds the main queue."
  type        = string
}

variable "main_routing_key" {
  description = "Routing key used to bind the main queue to main_source_exchange. Ignored by fanout exchanges but still required for the binding."
  type        = string
}

variable "dlq_source_exchange" {
  description = "Exchange that feeds the DLQ. Set as x-dead-letter-exchange on the main queue and used as the source for the DLQ binding."
  type        = string
}

variable "dlq_routing_key" {
  description = "Routing key used to bind the DLQ to dlq_source_exchange and as x-dead-letter-routing-key on the main queue. Defaults to \"{name}.dlq\"."
  type        = string
  default     = null
}

variable "dlq_name" {
  description = "DLQ queue name. Defaults to \"{name}.dlq\"."
  type        = string
  default     = null
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
