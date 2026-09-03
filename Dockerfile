FROM node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32 AS builder

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --ignore-scripts 

# Build the app
COPY . .
RUN npm run build

FROM nginx:alpine@sha256:a9ae6f6d078d477e21323310498e5196cb2b7c0aedd9e07b7306612077227d7c

# Replace default nginx config to listen on port 5731 and support SPA routing
COPY ./docker/nginx.default.conf /etc/nginx/conf.d/default.conf

# Copy built static site
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 5731

CMD ["nginx", "-g", "daemon off;"]
