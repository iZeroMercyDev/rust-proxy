# Build stage
FROM rust:1.88-bookworm AS builder

WORKDIR /app

# Copy project files
COPY . .

# Build release binary
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install CA certificates for HTTPS requests
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled binary
COPY --from=builder /app/target/release/rustProxy /usr/local/bin/rustProxy

# Render's web service needs the application to listen on its assigned port.
EXPOSE 8080

# Start proxy
CMD ["rustProxy"]
