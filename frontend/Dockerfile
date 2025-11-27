# ---- Builder Stage ----
FROM node:14-alpine3.12 AS builder

# Install Python2 and build tools for node-sass
RUN apk add --no-cache python2 make g++

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the project
COPY . .

# Build the frontend
RUN npm run build


# ---- Nginx Stage ----
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Clean default nginx html directory
RUN rm -rf /usr/share/nginx/html/*

# Copy build output
COPY --from=builder /app/dist /usr/share/nginx/html/

EXPOSE 80