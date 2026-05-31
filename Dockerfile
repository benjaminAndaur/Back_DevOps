# ── Stage 1: builder ──────────────────────────────────────────────────────────
FROM node:18-slim AS builder

WORKDIR /app

COPY package*.json ./
# Instalar TODAS las dependencias (incluye devDependencies para build)
RUN npm ci

COPY . .

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
FROM node:18-alpine AS runtime

WORKDIR /app

# Instalar solo dependencias de producción
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copiar solo el código fuente desde builder
COPY --from=builder /app/server.js .

# Usuario no root (mínimo privilegio)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000

CMD ["node", "server.js"]
