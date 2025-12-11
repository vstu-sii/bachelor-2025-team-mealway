# Cборка фронтенда (Node.js)
FROM node:20-alpine AS builder

# Рабочая директория
WORKDIR /app

# Копируем package.json и package-lock.json / yarn.lock
COPY app/package*.json .

# Установка всех пакетов из package-lock.json. Более стабильная версия npm install 
RUN npm ci || npm install

# Копируем весь проект
COPY . .

# Собираем Next.js проект
RUN npm run build

# Nginx для отдачи фронтенда
FROM nginx:1.28.0-alpine AS production

# Удаляем дефолтный конфиг Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Копируем кастомный конфиг Nginx
COPY app/nginx.conf /etc/nginx/nginx.conf

# Копируем собранный фронтенд из builder
# Для  Next.js:
COPY --from=builder /app/.next /usr/share/nginx/html/.next
COPY  /app/public /usr/share/nginx/html/public


# Пробрасываем порт 3000
EXPOSE 3001

# Запуск Nginx
CMD ["nginx", "-g", "daemon off;"]
