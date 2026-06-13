terraform {
  required_providers {
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
    }
  }
}

resource "rabbitmq_user" "user" {
  name     = var.name
  password = var.password
}

resource "rabbitmq_permissions" "permissions" {
  user  = rabbitmq_user.user.name
  vhost = var.vhost

  permissions {
    configure = var.configure_pattern
    write     = var.write_pattern
    read      = var.read_pattern
  }
}
