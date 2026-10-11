# Releasing

MouseTune uses **trunk-based development** with **Conventional Commits** and **automated release PRs**
([release-please](https://github.com/googleapis/release-please)). Releases are free: no Apple Developer account,
no App Store. They are ad-hoc signed and distributed via GitHub Releases and a Homebrew tap.

```
feature branch ──PR (CI)──▶ main ──▶ release-please updates "Release PR"
                                          │ merge
                                          ▼
                                   tag vX.Y.Z + GitHub Release
                                          │
                                          ▼
                 test → build → zip + dmg + SHA256SUMS → upload → update Homebrew tap
```

## Day to day
- Branch from `main`, open a PR, keep it short-lived. **Squash-merge** and use a Conventional Commit PR title (CI enforces it):
  - `feat: …` → minor bump · `fix: …` → patch bump · `feat!: …` / `BREAKING CHANGE:` → major bump
  - `docs:`, `chore:`, `ci:`, `test:`, `refactor:` → no release by themselves
- CI (`ci.yml`) runs SwiftLint, tests on macOS 14 and 15, builds the app and the Xcode project. The `CI OK` job is the single required check.

## Cutting a release
1. release-please keeps a PR titled “chore(main): release X.Y.Z” open; it edits `version.txt` and `CHANGELOG.md`.
2. Merge it. The tag `vX.Y.Z` and a GitHub Release are created, and `release.yml` attaches
   `MouseTune-X.Y.Z.zip`, `.dmg` and `SHA256SUMS`, then updates the Homebrew cask.
3. Failed upload? Re-run via *Actions → Release → Run workflow* with the existing tag.

The version in the app comes from `version.txt` at build time (`./build.sh` writes it into the bundle's Info.plist).

## One-time repository setup
**Settings → Actions → General:** workflow permissions “Read and write” and enable
“Allow GitHub Actions to create and approve pull requests” (needed by release-please).

**Branch protection for `main`:** require pull requests, require the `CI OK` check, require linear history (squash only).

**Homebrew tap:**
1. Create a public repo **`<you>/homebrew-tap`** (empty, with a `README`).
2. Create a fine-grained personal access token with *Contents: read & write* on that repo only and store it as secret **`HOMEBREW_TAP_TOKEN`** in this repo.
3. Every release then commits `Casks/mousetune.rb` to the tap. Users install with `brew install --cask <you>/tap/mousetune`.

The cask removes the quarantine flag after install, so Gatekeeper doesn't block the unnotarized app.
Users of the manual download open it once via right-click → *Open*.

## Local dry run
```bash
./build.sh                  # build/MouseTune.app
scripts/package.sh          # build/dist/{zip,dmg,SHA256SUMS}
```

## Hardening notes
- Third-party actions are pinned to major versions and updated weekly by Dependabot. For stricter supply-chain security, pin them to commit SHAs.
- The release job only runs from `main` merges / manual dispatch; secrets are never exposed to PR builds.
