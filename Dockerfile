# Build stage
FROM golang:1.25-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Set working directory
WORKDIR /build

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build arguments for version information
ARG VERSION=dev
ARG COMMIT=unknown
ARG BUILD_DATE=unknown

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s -X github.com/thesprockee/golang-daemon-app-template/pkg/version.Version=${VERSION} \
              -X github.com/thesprockee/golang-daemon-app-template/pkg/version.Commit=${COMMIT} \
              -X github.com/thesprockee/golang-daemon-app-template/pkg/version.BuildDate=${BUILD_DATE}" \
    -o /build/app ./cmd/app

# Runtime stage
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/app /app/app

# Copy configuration files
COPY --from=builder /build/configs /app/configs

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/app/app", "--version"] || exit 1

# Run the application
ENTRYPOINT ["/app/app"]
CMD ["--config", "/app/configs/config.yaml"]
