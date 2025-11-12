# Используем образ Python 3.12. Slim - это версия, не содержущая некоторые стандартные пакеты Debian, вследствие чего она и весит меньше
FROM python:3.12-slim

# Настройки окружения:
# - PYTHONDONTWRITEBYTECODE=1 отключает создание .pyc файлов
# - PYTHONUNBUFFERED=1 заставляет Python писать логи сразу (без буфера)
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Устанавливаем системные зависимости:
# - build-essential: инструменты для сборки (gcc, make и т.д.)
# - libpq-dev: библиотеки для работы с PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Рабочая директория внутри контейнера
WORKDIR /app

# Устанавливаем зависимости из файла requirements.txt 
# В угоду легковесности образа не сохраняем кэш
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt


# Копируем весь проект внутрь контейнера
COPY . .

# Создаём необходимые директории для работы приложения:
# - /app/logs: для логов приложения
# - /root/.olamma: директория для моделей Ollama
RUN mkdir -p /app/logs \
    && mkdir -p /app/.ollama

# Создаём непривилегированного пользователя appuser и назначаем ему права на директории
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Открываем порт 8000
EXPOSE 8000