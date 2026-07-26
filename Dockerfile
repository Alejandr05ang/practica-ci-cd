# Etapa 1: Construcción y Pruebas
FROM node:22-alpine AS builder
WORKDIR /app
RUN npm install -g npm@latest
COPY package*.json ./
RUN npm ci
COPY . .
# Si esto falla, el build se detiene inmediatamente
RUN npm test 

# Etapa 2: Imagen Final 
FROM node:22-alpine
WORKDIR /app
RUN npm install -g npm@latest
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/server.js ./
COPY --from=builder /app/db.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/data ./data 
EXPOSE 3000
CMD ["node", "server.js"]