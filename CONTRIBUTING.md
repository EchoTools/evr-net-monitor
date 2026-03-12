# Contributing

## Setup

```bash
git clone git@github.com:echotools/evr-net-monitor.git
cd evr-net-monitor
go mod download
```

## Workflow

1. Create a branch from `main`
2. Make focused changes
3. Run checks
4. Open PR

## Required local checks

```bash
just fmt
just vet
just test
```

Or run everything:

```bash
just check
```

## Versioned binaries (local)

```bash
just build-linux v1.2.3
just build-windows v1.2.3
```

## Release process

1. Push a semantic version tag (for example `v1.2.3`)
2. Create GitHub release or prerelease for that tag
3. CI workflow attaches Linux/Windows artifacts to that release

## Commit style

- Prefer Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)
- Keep commits small and reviewable
