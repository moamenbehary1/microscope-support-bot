# =============================================================================
# Stage 1: Build
# Use the official Dart SDK image to compile the application.
# The 'dart' image includes the full SDK needed for compilation.
# =============================================================================
FROM dart:stable AS build

# Set the working directory inside the container
WORKDIR /app

# Copy only dependency files first to leverage Docker layer caching.
# If pubspec.* doesn't change, this layer is cached and dart pub get is skipped.
COPY pubspec.yaml pubspec.lock ./

# Install all dependencies (including dev dependencies for the build step)
RUN dart pub get

# Copy the rest of the source code
COPY bin/ bin/
COPY lib/ lib/

# Compile to a self-contained executable for a leaner production image.
# AOT compilation produces a native binary with no runtime dependency on the Dart SDK.
RUN dart compile exe bin/telegram_bot_cms.dart -o bin/server

# =============================================================================
# Stage 2: Production Runtime
# debian:slim includes the C runtime (glibc) required by Dart AOT binaries.
# Much smaller than the full dart image, but more compatible than scratch.
# =============================================================================
FROM debian:bookworm-slim AS runtime

# Install CA certificates for HTTPS calls (Firebase, Telegram API)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the build stage
COPY --from=build /app/bin/server /app/bin/server

# Set the working directory
WORKDIR /app

# Command to run the compiled bot executable
CMD ["/app/bin/server"]
