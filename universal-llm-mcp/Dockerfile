# Build stage
FROM node:20-slim AS builder

WORKDIR /app

# Corepack enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

# Runner stage
FROM node:20-slim AS runner

WORKDIR /app

# Production dependencies only
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

COPY --from=builder /app/dist ./dist
COPY config.json ./

# Security: Non-root user
USER node

EXPOSE 3355

CMD ["node", "dist/start-server.js"]
