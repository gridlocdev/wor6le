# Stage 1: Build Flutter web app
FROM debian:bookworm-slim AS build

# Define build argument for base href (default to relative paths)
ARG BASE_HREF=/games/wor6le/

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for build
RUN useradd -m -u 1001 flutteruser

# Install Flutter SDK
ENV FLUTTER_HOME=/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    chown -R flutteruser:flutteruser ${FLUTTER_HOME} && \
    git config --global --add safe.directory ${FLUTTER_HOME}

# Switch to non-root user and configure Flutter
USER flutteruser
RUN flutter config --enable-web && \
    flutter precache --web && \
    flutter doctor -v

# Set working directory
WORKDIR /app

# Copy project files (switch to root temporarily, then back)
USER root
COPY --chown=flutteruser:flutteruser pubspec.yaml pubspec.lock ./
COPY --chown=flutteruser:flutteruser assets ./assets
COPY --chown=flutteruser:flutteruser lib ./lib
COPY --chown=flutteruser:flutteruser web ./web
COPY --chown=flutteruser:flutteruser analysis_options.yaml ./

# Switch back to non-root user
USER flutteruser

# Get packages
RUN flutter pub get

# Build Flutter web app with configurable base href
RUN flutter build web --release --base-href ${BASE_HREF}

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
