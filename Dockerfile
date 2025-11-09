# Stage 1: Build Flutter web app
FROM debian:bookworm-slim AS build

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
ENV FLUTTER_HOME=/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    flutter config --enable-web && \
    flutter precache --web && \
    flutter doctor -v

# Set working directory
WORKDIR /app

# Copy project files
COPY pubspec.yaml pubspec.lock ./
COPY assets ./assets
COPY lib ./lib
COPY web ./web
COPY analysis_options.yaml ./

# Get packages
RUN flutter pub get

# Build Flutter web app
RUN flutter build web --release

# Stage 2: Serve with nginx
FROM nginx:alpine AS serve

# Create non-root user
RUN addgroup -g 1001 -S nginx-user && \
    adduser -u 1001 -S nginx-user -G nginx-user

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Update nginx to run on port 8080 (non-privileged port)
RUN sed -i 's/listen\s*80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
    sed -i '/user  nginx;/d' /etc/nginx/nginx.conf && \
    chown -R nginx-user:nginx-user /usr/share/nginx/html && \
    chown -R nginx-user:nginx-user /var/cache/nginx && \
    chown -R nginx-user:nginx-user /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx-user:nginx-user /var/run/nginx.pid

# Switch to non-root user
USER nginx-user

# Expose port 8080
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
