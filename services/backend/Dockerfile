# Используем образ Python 3.11. Slim - это версия, не содержущая некоторые стандартные пакеты Debian, вследствие чего она и весит меньше
FROM python:3.11-slim

# Настройки окружения:
# - PYTHONDONTWRITEBYTECODE=1 отключает создание .pyc файлов, т.е. скопмпилированных файлов модулей python
# - PYTHONUNBUFFERED=1 заставляет Python писать логи сразу, а не сохранять их в буфер
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


# Добавляем .local/bin в PATH
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/docs')" || exit 1

# Запуск приложения
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
