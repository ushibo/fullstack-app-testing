# Fullstack Application (NestJS + React)

Современное веб-приложение на основе NestJS (бэкенд) и React (фронтенд), упакованное в Docker контейнеры с настроенным CI/CD на основе GitHub Actions.

## 🏠 Архитектура проекта

Проект организован в монорепозиторий и состоит из следующих компонентов:

- **Backend**: NestJS API (/apps/backend)
- **Frontend**: React SPA (/apps/frontend)
- **Deployment**: Docker + Nginx конфигурация (/infra)

## 🚀 Возможности

- 🔄 Микросервисная архитектура
- 🔒 Современные практики веб-разработки
- 📦 Контейнеризация с Docker
- 🚢 Автоматический CI/CD процесс
- 🌐 Nginx в качестве обратного прокси и для раздачи статики

## 🛠️ Технологии

- **Backend**: [NestJS](https://nestjs.com/) (TypeScript-based Node.js framework)
- **Frontend**: [React](https://reactjs.org/) + [Vite](https://vitejs.dev/)
- **Deployment**: [Docker](https://www.docker.com/), [Docker Compose](https://docs.docker.com/compose/), [Nginx](https://nginx.org/)
- **CI/CD**: [GitHub Actions](https://github.com/features/actions)

## 🔧 Локальная установка и запуск

### Требования

- Node.js (v18+)
- npm (v8+)
- Docker и Docker Compose

### Запуск для разработки

1. **Клонировать репозиторий**
   ```bash
   git clone <repository-url>
   cd fullstack-app
   ```

2. **Запустить бэкенд (NestJS)**
   ```bash
   cd apps/backend
   npm install
   npm run start:dev
   ```
   Бэкенд будет доступен на http://localhost:3000

3. **Запустить фронтенд (React)**
   ```bash
   cd apps/frontend
   npm install
   npm run dev
   ```
   Фронтенд будет доступен на http://localhost:5173

### Запуск с Docker Compose

```bash
# Запустить всё приложение в Docker
docker-compose -f infra/docker/docker-compose.yml up --build
```

После запуска приложение будет доступно по адресу: http://localhost

## 📦 Деплой

Приложение настроено для автоматического деплоя через GitHub Actions после успешной сборки.

### Ручной деплой

1. Убедитесь, что у вас есть доступ к серверу
2. Подготовьте переменные окружения для деплоя
3. Запустите скрипт деплоя:
   ```bash
   bash infra/scripts/deploy.sh
   ```

## 🧪 Тестирование

### Бэкенд тесты
```bash
cd apps/backend
npm run test       # Unit тесты
npm run test:e2e   # E2E тесты
```

### Фронтенд тесты
```bash
cd apps/frontend
npm run test
```

## 👨‍💻 Разработчики

- Ваше имя ([GitHub](https://github.com/username))

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. Подробности в файле [LICENSE](LICENSE). 