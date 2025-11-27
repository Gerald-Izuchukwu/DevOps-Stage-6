# Node.js Todos API
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source
COPY . .

EXPOSE 8082

CMD ["node", "server.js"]