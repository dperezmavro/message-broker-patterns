variable "name" {
  description = "RabbitMQ username."
  type        = string
}

variable "password" {
  description = "RabbitMQ user password."
  type        = string
  sensitive   = true
}

variable "vhost" {
  description = "Vhost the permissions apply to."
  type        = string
}

variable "configure_pattern" {
  description = "Regex of resources the user can declare/delete."
  type        = string
  default     = ".*"
}

variable "write_pattern" {
  description = "Regex of resources the user can publish to."
  type        = string
  default     = ".*"
}

variable "read_pattern" {
  description = "Regex of resources the user can consume from."
  type        = string
  default     = ".*"
}
