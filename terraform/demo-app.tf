# Create a virtual host
resource "rabbitmq_vhost" "application" {
  name = "demo-app"
}

resource "rabbitmq_user" "producer" {
  name     = "producer"
  password = "producer"
  # tags     = ["administrator", "management"]
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

resource "rabbitmq_exchange" "exchange" {
  name  = "demo-app"
  vhost = rabbitmq_permissions.producer.vhost

  settings {
    type        = "fanout"
    durable     = false
    auto_delete = true
  }
}