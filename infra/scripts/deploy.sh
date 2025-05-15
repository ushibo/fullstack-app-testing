#!/bin/bash

# Скрипт деплоя приложения

set -e

# Переменные
REPO_URL=${REPO_URL:-"ghcr.io/username"}
COMPOSE_FILE="infra/docker/docker-compose.prod.yml"
APP_DIR="/opt/fullstack-app"

# Функция для вывода сообщений
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Проверка наличия Docker и Docker Compose
if ! command -v docker &> /dev/null; then
  log "Docker не установлен. Устанавливаем..."
  curl -fsSL https://get.docker.com | sh
  log "Docker установлен"
fi

# Создаем директорию приложения
log "Создаем директорию приложения..."
mkdir -p $APP_DIR

# Копируем файлы конфигурации
log "Копируем конфигурационные файлы..."
cp $COMPOSE_FILE $APP_DIR/docker-compose.yml

# Аутентификация в реестре контейнеров, если токен предоставлен
if [ ! -z "$GITHUB_TOKEN" ]; then
  log "Аутентификация в GitHub Container Registry..."
  echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_REPOSITORY_OWNER --password-stdin
fi

# Параметры запуска
export GITHUB_REPOSITORY_OWNER=${GITHUB_REPOSITORY_OWNER:-"username"}

# Остановка и удаление старых контейнеров
log "Останавливаем старые контейнеры..."
cd $APP_DIR
docker-compose down || true

# Получение последних образов
log "Получаем последние образы..."
docker-compose pull

# Запуск приложения
log "Запускаем приложение..."
docker-compose up -d

# Проверка статуса
log "Проверяем статус..."
docker-compose ps

log "Деплой завершен успешно!" 