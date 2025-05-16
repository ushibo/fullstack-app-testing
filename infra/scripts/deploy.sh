#!/bin/bash

# Скрипт деплоя приложения

set -e  # Завершить при первой ошибке
set -o pipefail  # Проверять ошибки в пайпах

# Переменные по умолчанию
DEPLOY_DIR="${DEPLOY_DIR:-/app}"
REGISTRY="${REGISTRY:-ghcr.io}"
BACKEND_IMAGE="${BACKEND_IMAGE:-fullstack-app-backend}"
FRONTEND_IMAGE="${FRONTEND_IMAGE:-fullstack-app-frontend}"
TAG="${TAG:-latest}"
GITHUB_REPOSITORY_OWNER="${GITHUB_REPOSITORY_OWNER:-username}"
BACKUP_FILE="/tmp/docker-compose-state-$(date +%s).json"

# Функция для вывода сообщений
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Функция для вывода ошибок и завершения скрипта
fail() {
  log "❌ ОШИБКА: $1"
  if [ -f "$BACKUP_FILE" ] && [ "$2" = "restore" ]; then
    log "Восстанавливаем предыдущее состояние контейнеров..."
    docker compose down --remove-orphans &>/dev/null || true
    docker-compose config > docker-compose.yml
    docker-compose up -d
    rm -f "$BACKUP_FILE"
    log "Предыдущее состояние восстановлено."
  fi
  exit 1
}

# Проверяем наличие директории деплоя
if [ ! -d "$DEPLOY_DIR" ]; then
  log "Создаем директорию $DEPLOY_DIR..."
  mkdir -p "$DEPLOY_DIR" || fail "Не удалось создать директорию $DEPLOY_DIR"
fi

# Переходим в директорию деплоя
cd "$DEPLOY_DIR" || fail "Не удалось перейти в директорию $DEPLOY_DIR"
log "Рабочая директория: $(pwd)"

# Проверяем наличие файла docker-compose.prod.yml
if [ -f "docker-compose.prod.yml" ]; then
  log "Переименовываем docker-compose.prod.yml в docker-compose.yml..."
  mv docker-compose.prod.yml docker-compose.yml || fail "Не удалось переименовать файл docker-compose"
fi

# Проверяем что docker-compose.yml существует
if [ ! -f "docker-compose.yml" ]; then
  fail "Файл docker-compose.yml не найден!"
fi

# Создаем файл .env для docker-compose
log "Создаем файл .env с настройками..."
cat > .env << EOF || fail "Не удалось создать файл .env"
REGISTRY=$REGISTRY
GITHUB_REPOSITORY_OWNER=$GITHUB_REPOSITORY_OWNER
FRONTEND_IMAGE=$FRONTEND_IMAGE
BACKEND_IMAGE=$BACKEND_IMAGE
TAG=$TAG
EOF

# Аутентификация в GitHub Container Registry
if [ ! -z "$GITHUB_TOKEN" ]; then
  log "Аутентификация в GitHub Container Registry..."
  echo "$GITHUB_TOKEN" | docker login $REGISTRY -u $GITHUB_REPOSITORY_OWNER --password-stdin || fail "Ошибка аутентификации в Container Registry"
fi

# Получаем последние образы
log "Получаем последние образы..."
docker pull $REGISTRY/$GITHUB_REPOSITORY_OWNER/$BACKEND_IMAGE:$TAG || fail "Не удалось получить образ бэкенда"
docker pull $REGISTRY/$GITHUB_REPOSITORY_OWNER/$FRONTEND_IMAGE:$TAG || fail "Не удалось получить образ фронтенда"

# Сохраняем текущее состояние запущенных контейнеров
log "Сохраняем состояние текущих контейнеров..."
if docker compose ps --format json > "$BACKUP_FILE" 2>/dev/null; then
  log "Состояние сохранено в $BACKUP_FILE"
else
  log "Нет запущенных контейнеров или не удалось сохранить состояние"
  echo "[]" > "$BACKUP_FILE"
fi

# Останавливаем и удаляем старые контейнеры
log "Останавливаем старые контейнеры..."
docker compose down || fail "Не удалось остановить предыдущие контейнеры" "restore"

# Запускаем приложение
log "Запускаем приложение..."
if ! docker compose up -d --remove-orphans; then
  fail "Не удалось запустить контейнеры, восстанавливаем предыдущее состояние" "restore"
fi

# Проверка работоспособности
log "Проверяем доступность приложения..."
sleep 10
if ! curl --silent --fail http://localhost/api/health; then
  fail "Проверка доступности приложения не удалась, восстанавливаем предыдущее состояние" "restore"
fi

# Деплой успешен, удаляем резервную копию
rm -f "$BACKUP_FILE"
log "🚀 Деплой успешно завершен!"

# Очистка неиспользуемых образов
log "Очищаем неиспользуемые образы..."
docker image prune -f 