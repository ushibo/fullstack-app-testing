#!/bin/bash

# Скрипт деплоя приложения

set -e

# Переменные по умолчанию
DEPLOY_DIR="${DEPLOY_DIR:-/app}"
REGISTRY="${REGISTRY:-ghcr.io}"
BACKEND_IMAGE="${BACKEND_IMAGE:-fullstack-app-backend}"
FRONTEND_IMAGE="${FRONTEND_IMAGE:-fullstack-app-frontend}"
TAG="${TAG:-latest}"
GITHUB_REPOSITORY_OWNER="${GITHUB_REPOSITORY_OWNER:-username}"

# Функция для вывода сообщений
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Проверяем наличие директории деплоя
if [ ! -d "$DEPLOY_DIR" ]; then
  log "Создаем директорию $DEPLOY_DIR..."
  mkdir -p "$DEPLOY_DIR"
fi

# Переходим в директорию деплоя
cd "$DEPLOY_DIR"
log "Рабочая директория: $(pwd)"

# Проверяем наличие файла docker-compose.prod.yml
if [ -f "docker-compose.prod.yml" ]; then
  log "Переименовываем docker-compose.prod.yml в docker-compose.yml..."
  mv docker-compose.prod.yml docker-compose.yml
fi

# Создаем файл .env для docker-compose
log "Создаем файл .env с настройками..."
cat > .env << EOF
REGISTRY=$REGISTRY
GITHUB_REPOSITORY_OWNER=$GITHUB_REPOSITORY_OWNER
FRONTEND_IMAGE=$FRONTEND_IMAGE
BACKEND_IMAGE=$BACKEND_IMAGE
TAG=$TAG
EOF

# Аутентификация в GitHub Container Registry
if [ ! -z "$GITHUB_TOKEN" ]; then
  log "Аутентификация в GitHub Container Registry..."
  echo "$GITHUB_TOKEN" | docker login $REGISTRY -u $GITHUB_REPOSITORY_OWNER --password-stdin
  if [ $? -ne 0 ]; then
    log "❌ Ошибка аутентификации в Container Registry"
    exit 1
  fi
fi

# Получаем последние образы
log "Получаем последние образы..."
docker pull $REGISTRY/$GITHUB_REPOSITORY_OWNER/$BACKEND_IMAGE:$TAG
docker pull $REGISTRY/$GITHUB_REPOSITORY_OWNER/$FRONTEND_IMAGE:$TAG

# Останавливаем и удаляем старые контейнеры
log "Останавливаем старые контейнеры..."
docker compose down

# Запускаем приложение
log "Запускаем приложение..."
docker compose up -d --remove-orphans

# Проверка работоспособности
log "Проверяем доступность приложения..."
sleep 10
if curl --silent --fail http://localhost/api/health; then
  log "🚀 Деплой успешно завершен!"
else
  log "⚠️ Проверка доступности не удалась, но продолжаем..."
fi

# Очистка неиспользуемых образов
log "Очищаем неиспользуемые образы..."
docker image prune -f

log "Деплой успешно завершен!" 