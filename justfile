set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

app_name := "evr-net-monitor"

default:
	@just --list

build version="":
	@mkdir -p bin
	@ver="{{version}}"; \
	if [[ -z "$ver" ]]; then ver="$(git describe --tags --abbrev=0 2>/dev/null || true)"; fi; \
	if [[ -z "$ver" ]]; then ver="0.0.0-dev"; fi; \
	GOWORK=off go build -trimpath -ldflags "-s -w -X main.Version=$ver" -o "bin/{{app_name}}" .; \
	echo "Built bin/{{app_name}} ($ver)"

run:
	@GOWORK=off go run .

test:
	@GOWORK=off go test -v ./...

coverage:
	@GOWORK=off go test -v -coverprofile=coverage.out ./...
	@go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

fmt:
	@GOWORK=off go fmt ./...

lint:
	@if command -v golangci-lint >/dev/null; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed. Run: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

vet:
	@GOWORK=off go vet ./...

tidy:
	@GOWORK=off go mod tidy

version:
	@echo "Version: $(git describe --tags --always --dirty 2>/dev/null || echo dev)"
	@echo "Commit:  $(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
	@echo "Build Date: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"

clean:
	@rm -rf bin dist coverage.out coverage.html
	@echo "Clean complete"

docker-build:
	@docker build -t {{app_name}}:latest .

docker-run:
	@docker run --rm -p 8080:8080 {{app_name}}:latest

docker-compose-up:
	@docker compose up --build

docker-compose-down:
	@docker compose down

install-tools:
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

deps:
	@GOWORK=off go mod download

check:
	@just fmt
	@just vet
	@just lint
	@just test

build-windows version="":
	@mkdir -p dist
	@ver="{{version}}"; \
	if [[ -z "$ver" ]]; then ver="$(git describe --tags --abbrev=0 2>/dev/null || true)"; fi; \
	if [[ -z "$ver" ]]; then ver="0.0.0-dev"; fi; \
	if ! printf '%s' "$ver" | grep -Eq '^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'; then \
		echo "VERSION must be semver (example: 1.2.3 or v1.2.3)" >&2; \
		exit 2; \
	fi; \
	clean="${ver#v}"; \
	out="dist/evr-net-monitor_${clean}_windows_amd64.exe"; \
	GOOS=windows GOARCH=amd64 GOWORK=off go build -trimpath -ldflags "-s -w -X main.Version=$ver" -o "$out" .; \
	echo "Built $out"

build-linux version="":
	@mkdir -p dist
	@ver="{{version}}"; \
	if [[ -z "$ver" ]]; then ver="$(git describe --tags --abbrev=0 2>/dev/null || true)"; fi; \
	if [[ -z "$ver" ]]; then ver="0.0.0-dev"; fi; \
	if ! printf '%s' "$ver" | grep -Eq '^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'; then \
		echo "VERSION must be semver (example: 1.2.3 or v1.2.3)" >&2; \
		exit 2; \
	fi; \
	clean="${ver#v}"; \
	out="dist/evr-net-monitor_${clean}_linux_amd64"; \
	GOWORK=off go build -trimpath -ldflags "-s -w -X main.Version=$ver" -o "$out" .; \
	echo "Built $out"
