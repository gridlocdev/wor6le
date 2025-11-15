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

# Build Flutter web app with relative paths for subdirectory hosting
RUN flutter build web --release --base-href ./

# Stage 2: Serve with busybox httpd
FROM busybox:latest AS serve

# Create non-root user
RUN addgroup -g 1001 appuser && \
    adduser -u 1001 -G appuser -D appuser

# Create directory for web content
RUN mkdir -p /www

# Copy built web app from build stage
COPY --from=build --chown=appuser:appuser /app/build/web /www

# Switch to non-root user
USER appuser

# Expose port 8080
EXPOSE 8080

# Start busybox httpd server
# -f: foreground mode
# -p: port
# -h: home directory
CMD ["httpd", "-f", "-p", "8080", "-h", "/www"]
