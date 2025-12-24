# Universal LLM MCP - Dockerfile
FROM node:20-alpine

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# Source
COPY dist ./dist
COPY config.json ./
COPY certs ./certs

# Create data directory
RUN mkdir -p /app/data

# Port
EXPOSE 3002

# Start
CMD ["node", "dist/index.js"]
