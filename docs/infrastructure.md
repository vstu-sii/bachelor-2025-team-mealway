1. Запуск локального окружения
Предварительные требования:
    Docker Desktop (или Docker Engine + Compose на Linux)
    Git
    Опционально: VS Code

Быстрый старт

# Клонируйте репозиторий
git clone https://github.com/<ваш-юзернейм>/bachelor-2025-team-mealway.git

# Создайте .env (пример ниже) и запустите
docker compose -f docker-compose.dev.yml up --build


Пример .env

BD_NAME=
BD_USER=
BD_PASSWORD=

EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=

Как работать с кодом

Быстрая пересборка:

docker compose -f docker-compose.dev.yml down && docker compose -f docker-compose.dev.yml up --build

Войти в контейнер:

docker exec -it <имя_контейнера> bash


2. Troubleshooting guide

itHub Actions падает

Проверьте:

    Синтаксис YAML в .github/workflows/.
    Установлены ли нужные версии FastAPI в workflow.
    Правильно ли указаны команды npm install, npm test.

Решение:

    Убедитесь, что workflow‑файл корректен и проходит проверку синтаксиса.
    В блоке uses: задайте поддерживаемую версию FastAPI.
    Проверьте, что команды сборки и тестирования совпадают с теми, что используются локально.


3. Архитектура инфраструктуры

Backend - HTML, бизнес‑логика
PostgreSQL — хранилище данных
Docker Compose — orchestrator для запуска всех сервисов локально.
GitHub Actions — CI/CD для автоматизации сборки, тестирования и деплоя.


4. Cheat sheet для команды
Docker Compose
Команда 	Описание
docker compose up 	Запустить все сервисы
docker compose up --build 	Пересобрать и запустить
docker compose down 	Остановить и удалить контейнеры
docker compose logs 	Логи сервиса
docker compose exec bash 	Шелл внутри контейнера
Git — основные команды
Команда 	Описание
git clone <repo-url> 	Клонировать репозиторий
git checkout -b feat/<название-фичи> 	Создать новую ветку для фичи
git status 	Проверить состояние рабочей директории
git add . 	Добавить все изменения в индекс
git commit -m "feat: описание изменений" 	Сделать коммит
git push origin feat/<название-фичи> 	Отправить ветку на GitHub
git fetch && git rebase origin/main 	Обновить ветку с main
git pull 	Получить последние изменения
git merge <branch> 	Слить ветку в текущую
git log --oneline --graph 	Просмотреть историю коммитов