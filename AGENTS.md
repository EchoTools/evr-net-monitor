# Agent Notes

## Project

`evr-net-monitor` is a Go terminal monitor for Echo VR network quality.

## Build and test

Use `just` recipes:

```bash
just build
just test
just check
```

Versioned artifacts:

```bash
just build-linux v1.2.3
just build-windows v1.2.3
```

## Release automation

Release workflow is in `.github/workflows/release-artifacts.yml` and runs for release + prerelease events.

It must:

- build Linux and Windows binaries
- embed semantic version in binary (`main.Version`)
- include version in filename
- upload immutable workflow artifacts
- attach assets to the GitHub release
