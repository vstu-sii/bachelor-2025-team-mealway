# Cборка фронтенда (Node.js)
FROM node:20-alpine AS builder

# Рабочая директория
WORKDIR /app

# Копируем package.json и package-lock.json / yarn.lock
COPY package*.json .

# Установка всех пакетов из package-lock.json. Более стабильная версия npm install 
RUN npm ci

# Копируем весь проект
COPY . .

# Собираем Next.js проект
RUN npm run build

# Nginx для отдачи фронтенда
FROM nginx:20-alpine AS production

# Удаляем дефолтный конфиг Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Копируем кастомный конфиг Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем собранный фронтенд из builder
# Для обычного Next.js (SSR):
COPY --from=builder /app/.next /usr/share/nginx/html/.next
COPY --from=builder /app/public /usr/share/nginx/html/public
# Для static export:
# COPY --from=builder /app/out /usr/share/nginx/html

# Пробрасываем порт 3000
EXPOSE 3000

# Запуск Nginx
CMD ["nginx", "-g", "daemon off;"]
