# Contributing

Thanks for helping! MouseTune aims to stay **small, dependency-free and offline**. Please keep changes in that spirit.

## Setup
```bash
swift build && swift test   # or open MouseTune.xcodeproj in Xcode
```

## Guidelines
- Apple frameworks only; no third-party packages, no network, no telemetry.
- Left and right mouse clicks must never be intercepted.
- The event-tap callback must stay fast: no disk I/O or blocking work, dispatch to main for UI/actions.
- Keep the Swift 5 language mode (`swift-tools-version:5.9`).
- Add unit tests for pure logic (`ScrollScaler`, `Config`, …). Hardware-dependent behavior should be described in the PR as manually tested.

## Adding a language
1. Add a case to `Language` in `Sources/MouseTune/Localization/Language.swift` (with its native name and resolution rule).
2. Copy `Strings+en.swift` to `Strings+xx.swift`, translate every value, and register the table in `Strings.table(for:)` / `Strings.text`.
3. `swift test` fails if a key is missing or a `%` placeholder doesn't match.

## Pull requests
Use a [Conventional Commits](https://www.conventionalcommits.org) PR title (`feat: …`, `fix: …`, `docs: …`) — PRs are squash-merged and the title drives versioning and the changelog. See [docs/RELEASING.md](docs/RELEASING.md).

Describe what changed and how you tested it (macOS version, mouse model). Keep PRs focused.
