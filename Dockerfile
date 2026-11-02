# node 26
FROM node:26-alpine@sha256:0b36e8c136b94cd4fcf02188228e76c31ad5872eef3fec8cbd2eee500cfd9e80 AS builder
# Include dependencies from build layer
ARG BUILDKIT_SBOM_SCAN_STAGE=true 
# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json .npmrc ./
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN npm ci --ignore-scripts

# Build the app
COPY . .
RUN npm run build

FROM nginx:stable-alpine-slim@sha256:dede8895648b461178c3bc604f7eed4423efe5220b2c4d839f5eb3d34ac3f8f7

RUN apk add --no-cache pcre2=10.49-r0

# Replace default nginx config to listen on port 5731 and support SPA routing
COPY ./docker/nginx.default.conf /etc/nginx/conf.d/default.conf

# Copy built static site
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 5731

CMD ["nginx", "-g", "daemon off;"]
