# Запуск локального окружения
Предварительные требования: 
- Docker Desktop (или Docker Engine + Compose)
- Git
- VS Code

---

# Быстрый старт

```bash
#Клонируйте репозиторий командой:
git clone https://github.com/<ваш-юзернейм>/bachelor-2025-team-mealway.git

#Создайте .env (пример ниже) и запустите:
docker compose -f docker-compose.dev.yml up --build
```

---

**Что запускается?**
- Ollama → http://localhost:11434 — API для работы с LLM
- Prometheus → http://localhost:9090 — сбор метрик
- Grafana → http://localhost:3000 — визуализация метрик

---

**Пример .env**
```
BD_NAME=
BD_USER=
BD_PASSWORD=

EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
```

---

Как работать с кодом

- Быстрая пересборка

```
docker compose -f docker-compose.dev.yml down && docker compose -f docker-compose.dev.yml up --build
```

- Войти в контейнер:

```
docker exec -it <имя_контейнера> bash
```

---

# Troubleshooting guide

**Если Grafana не видит Prometheus, то проверь:**
- Открыт ли http://localhost:9090
- Правильно ли настроен источник данных в Grafana

---

**Если GitHub Actions падает, то проверьте:**
- Синтаксис YAML в .github/workflows/
- Установлены ли нужные версии FastAPI в workflow

---

**Если Ollama не запускается или не отвечает, то:**
- Убедитесь, что папка .ollama_data создана и доступна
- Попробуйте запустить Ollama вручную и проверить логи:
```
docker logs ollama
```

--- 


# Архитектура инфраструктуры

Система состоит из следующих компонентов:
- Backend - HTML, бизнес‑логика
- PostgreSQL — хранилище данных
- Docker Compose — orchestrator для запуска всех сервисов локально
- GitHub Actions — CI/CD для автоматизации сборки, тестирования и деплоя
- Grafana — визуализация метрик из Prometheus
- Prometheus — сбор метрик производительности и состояния сервисов
- Langfuse — для трассировки, логирования и оценки вызовов LLM

---

# Cheat sheet для команды


**Docker Compose**

| Команда | Описание |
|---------|----------|
| `docker compose up` | Запустить все сервисы |
| `docker compose up --build` | Пересобрать и запустить |
| `docker compose down` | Остановить и удалить контейнеры |
| `docker compose logs <service>` | Посмотреть логи сервиса |

---

**Git**

| Команда | Описание |
|---------|----------|
| `git checkout -b feat/название ветки` | Создать новую ветку |
| `git add . && git commit -m "feat: добавил новую функцию"` | Закоммитить изменения |
| `git push origin feat/название-фичи` | Запушить ветку на GitHub |
| `git fetch && git rebase origin/main` | Обновить ветку с main |

---

**Типы коммитов**

| Тип | Описание |
|-----|----------|
| `feat` | Новая фича |
| `fix` | Исправление бага |
| `docs` | Изменения в документации |
| `style` | Форматирование, стили |
| `refactor` | Рефакторинг |
| `test` | Изменения в тестах |
| `chore` | Прочие изменения |

---
**GitHub Actions**

- `.github/workflows/` — папка с workflow-файлами
- Пример workflow для Node.js:
```
name: FastAPI CI

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov
          
      - name: Run tests
        run: |
          pytest --cov=app --cov-report=xml
          
```
