#!/usr/bin/env bash
set -e

# Запускаем RabbitMQ в фоне
rabbitmq-server -detached

echo "⏳ Waiting for local RabbitMQ node to be ready..."

# Ждём пока локальная нода поднимется
until rabbitmqctl await_startup; do
  sleep 2
done

echo "✅ Local node is up"

echo "⏳ Waiting for rabbit1 to be ready..."

# Ждём первую ноду
until rabbitmqctl -n rabbit@rabbit1 ping; do
  sleep 2
done

echo "✅ rabbit1 is reachable"

# Останавливаем приложение перед join
rabbitmqctl stop_app

# На всякий случай чистим состояние
rabbitmqctl reset

# Присоединяемся к кластеру
rabbitmqctl join_cluster rabbit@rabbit1

# Запускаем обратно
rabbitmqctl start_app

echo "🎉 Joined cluster"

# Держим контейнер живым
tail -f /dev/null