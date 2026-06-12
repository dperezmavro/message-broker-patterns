#!/bin/bash
set -euo pipefail

COOKIE="unique-secret-cookie"
NODE1="rabbitmq-node-1@rabbitmq-node-1"
NODE2="rabbitmq-node-2@rabbitmq-node-2"
NODE3="rabbitmq-node-3@rabbitmq-node-3"

# rabbitmqctl reads the cookie from this file; write it explicitly since
# the RabbitMQ server process never starts on this container.
printf '%s' "$COOKIE" > /var/lib/rabbitmq/.erlang.cookie
chmod 400 /var/lib/rabbitmq/.erlang.cookie

wait_for_node() {
    local node=$1
    echo "Waiting for $node..."
    until rabbitmqctl -n "$node" -t 5 ping &>/dev/null; do
        echo "  $node not ready, retrying in 5s..."
        sleep 5
    done
    echo "  $node is up."
}

join_cluster() {
    local node=$1
    echo "Joining $node to cluster via $NODE1..."
    rabbitmqctl -n "$node" stop_app
    rabbitmqctl -n "$node" reset
    rabbitmqctl -n "$node" join_cluster "$NODE1"
    rabbitmqctl -n "$node" start_app
    echo "  $node joined."
}

wait_for_node "$NODE1"
wait_for_node "$NODE2"
wait_for_node "$NODE3"

join_cluster "$NODE2"
join_cluster "$NODE3"

echo ""
echo "=== Cluster Status ==="
rabbitmqctl -n "$NODE1" cluster_status
