# ---------- base ----------
FROM node:24-slim AS base
WORKDIR /app
# openssl é necessário para o schema engine do Prisma (migrations)
RUN apt-get update -y && apt-get install -y --no-install-recommends openssl \
  && rm -rf /var/lib/apt/lists/*

# ---------- deps ----------
FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

# ---------- dev (usado pelo docker-compose) ----------
FROM deps AS dev
ENV NODE_ENV=development
COPY . .
EXPOSE 3333
# Gera o Prisma Client, aplica as migrations e sobe em modo watch
CMD ["sh", "-c", "npx prisma generate && npx prisma migrate deploy && npm run start:dev"]

# ---------- build ----------
FROM deps AS build
COPY . .
RUN npx prisma generate && npx nest build && npm prune --omit=dev

# ---------- prod ----------
FROM base AS prod
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/prisma.config.ts /app/package.json ./
EXPOSE 3333
CMD ["node", "dist/main.js"]
