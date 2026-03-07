#!/bin/bash

# Скрипт для резервного копирования домашней директории пользователя
# Использование: ./backup_home_dir.sh username

# CONFIG
USERNAME="$1"
HOME_DIR="/home/${USERNAME}"
BACKUP_DIR="/tmp/backup/${USERNAME}"
LOGTAG="backup_home_dir"

# Проверка 1: передача аргумента
if [ $# -eq 0 ]; then
    echo "ERROR: Не указано имя пользователя"
    echo "Использование: ./backup_home_dir.sh username"
    exit 1
fi

# Проверка 2: Существует ли пользователь
if ! id "$USERNAME" &>/dev/null; then
    logger -t $LOGTAG "ERROR. Пользователь '$USERNAME' не существует"
    exit 1
fi

# Проверка 3: Существует ли каталог пользователя в /home
if [ ! -d "$HOME_DIR" ]; then
    logger -t $LOGTAG "ERROR. Каталог '$HOME_DIR' не существует"
    exit 1
fi

# Проверка 4: Существует ли каталог для резервных копий
if [ ! -d "/tmp/backup" ]; then
    mkdir -p "/tmp/backup"
    if [ $? -ne 0 ]; then
        logger -t $LOGTAG "ERROR. Не удалось создать каталог /tmp/backup"
        exit 1
    fi
    logger -t $LOGTAG "INFO. Создан каталог /tmp/backup"
fi

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        logger -t $LOGTAG "ERROR. Не удалось создать каталог '$BACKUP_DIR'"
        exit 1
    fi
    logger -t $LOGTAG "INFO. Создан каталог '$BACKUP_DIR'"
fi

# Начало резервного копирования
logger -t $LOGTAG "INFO. Начало резервного копирования домашней директории пользователя '$USERNAME'"
logger -t $LOGTAG "INFO. Источник: $HOME_DIR"
logger -t $LOGTAG "INFO. Назначение: $BACKUP_DIR"

# Выполнение резервного копирования с помощью rsync
# Опции:
# -a: архивный режим (сохраняет права, владельца, временные метки и т.д.)
# -v: подробный вывод
# -z: сжатие при передаче
# --delete: удалять файлы в назначении, которых нет в источнике (зеркальная копия)
rsync -avz --delete "$HOME_DIR/" "$BACKUP_DIR/"

# Завершение резервного копирования
if [ $? -eq 0 ]; then
    logger -t $LOGTAG "INFO. Резервное копирование для '$USERNAME' завершено успешно."
else
    logger -t $LOGTAG "ERROR. Не удалось выполнить резервное копирование для '$USERNAME'"
    exit 1
fi
