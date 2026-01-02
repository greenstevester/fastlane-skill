<p align="center">
  <img src="icon.png" alt="Fastlane Skill Icon" width="128" height="128">
</p>

# Fastlane Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-purple.svg)](https://claude.ai/code)
[![Fastlane](https://img.shields.io/badge/Fastlane-00F200?logo=fastlane&logoColor=white)](https://fastlane.tools/)

> 5 modular plugins for iOS/macOS app automation - install only what you need.

## Plugins

This marketplace provides **5 independent plugins** - install all or pick what you need:

| Plugin | Skill | Description |
|--------|-------|-------------|
| `setup-fastlane` | `/setup-fastlane` | Generate complete Fastlane configuration from Xcode project |
| `beta` | `/beta` | Build and upload to TestFlight for beta testing |
| `release` | `/release` | Submit to App Store for review and production release |
| `match` | `/match` | Set up code signing certificate management |
| `snapshot` | `/snapshot` | Automate App Store screenshot capture |

## What

Generates a complete Fastlane configuration by introspecting your Xcode project (extracts bundle ID, team ID, version from `.pbxproj`):

| Lane | Description |
|------|-------------|
| `test` | Run unit tests |
| `beta` | Build + upload to TestFlight |
| `release` | Submit TestFlight build to App Store |
| `lint` | Run SwiftLint |
| `ci` | Full CI workflow (lint → build → test) |
| `certificates_*` | Sync signing via `match` |

Plus: `Appfile`, `Matchfile`, `Deliverfile`, and metadata folder structure.

## Why

- **It's Nitrous oxide** - to super-charge your Fastlane setup/usage, so your focus is shipping
- **Zero config** - no manual entry of bundle IDs or team IDs
- **CI-ready** - optional [Xcode Cloud integration scripts](docs/xcode-cloud.md)

## How

**Prerequisites:** macOS with Xcode CLI tools, [Homebrew](https://brew.sh), and Fastlane (`brew install fastlane`)

### 1. Add the Marketplace

```
/plugin marketplace add greenstevester/fastlane-skill
```

### 2. Install Plugins

**Install all plugins:**
```
/plugin install setup-fastlane@fastlane-skill
/plugin install beta@fastlane-skill
/plugin install release@fastlane-skill
/plugin install match@fastlane-skill
/plugin install snapshot@fastlane-skill
```

**Or install only what you need:**
```
/plugin install setup-fastlane@fastlane-skill   # Just the initial setup
/plugin install match@fastlane-skill            # Just code signing
```

**Update to latest version:**
```
/plugin marketplace update fastlane-skill
```

Then restart Claude Code to load the plugins.

### 3. Run It

Navigate to your iOS/macOS project and run:

```
/setup-fastlane
```

### 4. Verify

```bash
fastlane lanes   # Lists: test, beta, release, lint, ci, certificates_*, etc.
```

### 5. Release Your App

**TestFlight Beta:**
```
/beta
```
Syncs certificates, increments build number, builds, and uploads to TestFlight.

**App Store Release:**
```
/release
```
Submits an existing TestFlight build to the App Store for review.

**Code Signing Setup:**
```
/match
```
Sets up Match for team certificate sharing via a private Git repo. Handles development, App Store, and ad hoc certificates.

**Automated Screenshots:**
```
/snapshot
```
Configures Snapshot to capture App Store screenshots across multiple devices and languages automatically.

## App Store Metadata

```bash
# Download existing metadata from App Store Connect
fastlane deliver download_metadata

# Push changes back
fastlane ios metadata
```

## CI/CD Integration

- **Xcode Cloud:** See [Xcode Cloud Setup Guide](docs/xcode-cloud.md)
- **GitHub Actions:** Coming soon

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No Xcode project detected | Run from directory containing `.xcodeproj` or `.xcworkspace` |
| Bundle ID not found | Ensure project has `PRODUCT_BUNDLE_IDENTIFIER` set |
| Fastlane not found | Run `brew install fastlane` |
| Code signing errors | Run `/match` to set up certificate management |
| Screenshot capture fails | Ensure UI test target exists and `SnapshotHelper.swift` is added |

## Local Development

To test changes locally before publishing:

**Option 1: Quick dev testing** (no install, changes picked up on restart)
```bash
claude --plugin-dir /path/to/fastlane-skill
```

**Option 2: Test full install flow**

First remove any existing installation:
```
/plugin marketplace remove fastlane-skill
```

Then add local directory as marketplace and install plugins:
```
/plugin marketplace add /path/to/fastlane-skill
/plugin install setup-fastlane@fastlane-skill
/plugin install match@fastlane-skill
# ... install whichever plugins you want to test
```

Restart Claude Code to load the plugins.

## Contributing

Issues and PRs welcome at [github.com/greenstevester/fastlane-skill](https://github.com/greenstevester/fastlane-skill).

## License

MIT
