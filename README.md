# EVR Net Monitor

Terminal network monitor for Echo VR connectivity quality.

## What it does

- Tracks ICMP and UDP probe latency/jitter/quality over time.
- Polls match presence and player pings.
- Captures headset session snapshots into `.echoreplay` output when valid data is available.
- Supports Base24 theming and semantic version embedding in binaries.

## Requirements

- Go 1.25+
- `just` (for task runner commands)

## Development

Common commands:

```bash
just build
just run
just test
just check
```

Versioned builds:

```bash
just build-linux v1.2.3
just build-windows v1.2.3
```

Artifacts are emitted to `dist/` with versioned filenames.

## Release automation

When a GitHub release is created (including prereleases), workflow
`.github/workflows/release-artifacts.yml`:

1. Builds Linux + Windows binaries
2. Embeds the release tag into `main.Version`
3. Names assets with semantic version in filename
4. Uploads immutable workflow artifacts (`overwrite: false`)
5. Attaches binaries to the release tag (no clobber)

Expected asset names:

- `evr-net-monitor_<version>_linux_amd64`
- `evr-net-monitor_<version>_windows_amd64.exe`

## Versioning

Semantic versioning is required for release tags (`vMAJOR.MINOR.PATCH` optional prerelease/build metadata).
