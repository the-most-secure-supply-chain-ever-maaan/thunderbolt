# node 26
FROM node:26-alpine@sha256:ef24c5053d50fdc3e4e56eb4e7ddb7861874ab0fdc797046ba897581deb8e868 AS builder
# Include dependencies from build layer
ARG BUILDKIT_SBOM_SCAN_STAGE=true 
# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --ignore-scripts 

# Build the app
COPY . .
RUN npm run build

# nginx 1.31.6 (alpine 3.24.1)
FROM nginx:alpine@sha256:df221db836e1754089190208cee7eeda94f233197056426eda74a43ab1abeac2

RUN apk add --no-cache libexpat=2.8.5-r0

# Replace default nginx config to listen on port 5731 and support SPA routing
COPY ./docker/nginx.default.conf /etc/nginx/conf.d/default.conf

# Copy built static site
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 5731

CMD ["nginx", "-g", "daemon off;"]
