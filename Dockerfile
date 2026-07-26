# Etapa 1: Construcción y Pruebas
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Si esto falla, el build se detiene inmediatamente
RUN npm test 

# Etapa 2: Imagen Final (Producción)
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/server.js ./
COPY --from=builder /app/db.js ./
COPY --from=builder /app/public ./public
# Se copia la carpeta data vacía para evitar errores si la app espera que exista
COPY --from=builder /app/data ./data 
EXPOSE 3000
CMD ["node", "server.js"]