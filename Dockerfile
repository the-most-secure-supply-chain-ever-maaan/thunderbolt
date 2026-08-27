FROM node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32 AS builder

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Build the app
COPY . .
RUN npm run build

FROM nginx:alpine@sha256:97d490c12ba55b4946b01546d1c3ed324e8d41ab1c9fcb2a616aa470620e5b46

# Replace default nginx config to listen on port 5731 and support SPA routing
COPY ./docker/nginx.default.conf /etc/nginx/conf.d/default.conf

# Copy built static site
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 5731

CMD ["nginx", "-g", "daemon off;"]
