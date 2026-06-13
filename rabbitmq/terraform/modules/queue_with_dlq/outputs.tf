output "queue_name" {
  value = rabbitmq_queue.main.name
}

output "dlq_name" {
  value = rabbitmq_queue.dlq.name
}

output "dlq_routing_key" {
  value = local.dlq_routing_key
}
