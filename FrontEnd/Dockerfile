# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:stable AS build-env
WORKDIR /app

# Copy dependency files and fetch packages
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source and build
COPY . .
RUN flutter build web

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80