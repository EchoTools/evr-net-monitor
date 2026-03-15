# CLAUDE.md — evr-net-monitor

## Project

`evr-net-monitor` is a Go terminal network monitor for Echo VR / nEVR platform connectivity quality. It runs as a single-binary TUI application that probes game server endpoints and displays real-time latency, jitter, and connection quality metrics.

Module path: `github.com/echotools/evr-net-monitor`

## Build & Test

Use `just` (task runner). All `go` commands must set `GOWORK=off` to avoid workspace interference.

```bash
just build               # Build to bin/evr-net-monitor
just run                 # go run .
just test                # go test -v ./...
just check               # fmt + vet + lint + test
just build-linux v1.2.3  # Cross-compile Linux amd64 → dist/
just build-windows v1.2.3 # Cross-compile Windows amd64 → dist/
```

Linting requires `golangci-lint`; install via `just install-tools`.

The `Version` variable in `main` is injected at build time via `-ldflags "-X main.Version=$ver"`. It must be a valid semver string; the binary falls back to `v0.0.0-dev` otherwise.

## Architecture

All code lives at the top level (`main` package) and in one internal package:

```
main.go              — CLI flags, TUI setup, probe loops, WebSocket login, match poller
internal/evr/        — EchoVR binary protocol types (one file per message type)
```

`main.go` is the sole entry point. Key subsystems:

- **ICMP prober** — uses `go-ping` to measure round-trip to a configurable host
- **UDP prober** — sends/receives EchoVR UDP ping packets (`udpPingRequestSymbol` / `udpPingAckSymbol`) to game server endpoints
- **WebSocket login** — authenticates against EchoVR login server using the `gorilla/websocket` client and EchoVR binary protocol
- **Match poller** — polls match presence and player ping samples via the login WebSocket session
- **TUI** — `termui/v3` widgets render rolling time-series charts, status panels, and error logs
- **EchoReplay capture** — snapshots valid headset session state to `.echoreplay` zip archives

`internal/evr` implements the EchoVR binary protocol: each file defines one packet type with its symbol constant, encode/decode logic, and uses `go-restruct` for struct-based binary marshalling.

## Conventions

- All probe and TUI state is gated behind `model.mu` (`sync.Mutex`); do not access `model` fields without holding the lock.
- Probe results flow through unbuffered channels; producers must not block on send.
- Error strings are stored in `probeStats.lastErr` and surfaced in the TUI error log without wrapping.
- Rolling windows (`latency`, `jitter`, `quality`, `recentOK`) are fixed-length slices; `seriesMaxPoints = 120` and `qualityWindowSize = 60` are the canonical limits.
- Use `go.uber.org/zap` for structured logging (file sink via `lumberjack`); do not use `log` or `fmt.Print*` for runtime output.
- `GOWORK=off` must be set for all `go` tool invocations to prevent workspace resolution outside this module.

## Dependencies

| Dependency | Role |
|---|---|
| `github.com/echotools/nevr-common/v4` | Shared nEVR platform types and proto definitions |
| `github.com/gizak/termui/v3` | Terminal UI widgets and rendering |
| `github.com/go-ping/ping` | ICMP probe implementation |
| `github.com/go-restruct/restruct` | Binary struct marshal/unmarshal for EchoVR protocol |
| `github.com/gofrs/uuid/v5` | UUID generation for session/match IDs |
| `github.com/gorilla/websocket` | WebSocket client for EchoVR login server |
| `github.com/klauspost/compress` | Compression for replay archive output |
| `go.uber.org/zap` | Structured logging |
| `google.golang.org/protobuf` | Protobuf runtime (via nevr-common) |
| `gopkg.in/natefinch/lumberjack.v2` | Log file rotation |
