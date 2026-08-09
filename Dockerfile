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
# Use the minimal runtime image (no SDK) to keep the final image small and secure.
# =============================================================================
FROM scratch AS runtime

# Copy the compiled binary from the build stage
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server

# Set the working directory (the app will look for .env relative to CWD)
WORKDIR /app

# Expose no ports (this is a polling bot, not a webhook server)
# If you switch to webhooks, uncomment and set the correct port:
# EXPOSE 8080

# Command to run the compiled bot executable
CMD ["/app/bin/server"]
