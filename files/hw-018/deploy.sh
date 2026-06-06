#!/bin/bash

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: скрипт необходимо запускать через sudo или от root."
    echo "Пример:"
    echo "  sudo $0"
    exit 1
fi

REPO_URL="https://github.com/1000karat/shvirtd-example-python.git"
APP_DIR="/opt/shvirtd-example-python"

echo "[1/4] Клонирование репозитория..."

if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
fi

git clone "$REPO_URL" "$APP_DIR"

echo "[2/4] Переход в каталог проекта..."
cd "$APP_DIR"

echo "[3/4] Сборка и запуск контейнеров..."
docker compose up -d --build

echo "[4/4] Проверка состояния контейнеров..."
docker compose ps

echo "Проект успешно запущен."