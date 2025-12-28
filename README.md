<p align="center">
  <img src="icon.png" alt="Fastlane Skill Icon" width="128" height="128">
</p>

# Fastlane Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-purple.svg)](https://claude.ai/code)
[![Fastlane](https://img.shields.io/badge/Fastlane-00F200?logo=fastlane&logoColor=white)](https://fastlane.tools/)

> One command to set up Fastlane for iOS/macOS apps - from zero to App Store ready.

## What

This skill generates a complete Fastlane configuration by introspecting your Xcode project. It extracts bundle ID, team ID, and version from your `.pbxproj`, then creates:

| Lane | Command | Description |
|------|---------|-------------|
| `test` | `fastlane ios test` | Run unit tests |
| `beta` | `fastlane ios beta` | Build + TestFlight |
| `release` | `fastlane ios release` | Build + App Store |
| `metadata` | `fastlane ios metadata` | Update listing (no build) |
| `screenshots` | `fastlane ios screenshots` | Upload screenshots |
| `sync_signing` | `fastlane ios sync_signing` | Sync certificates |

Plus: Full `fastlane/metadata/` folder structure for version-controlled App Store listings.

## Why

- **It's Nitrous oxide** - to super-charge your Fastlane setup/usage, so your focus is shipping
- **Zero config** - no manual entry of bundle IDs or team IDs
- **CI-ready** - optional Xcode Cloud integration scripts

## How

**Prerequisites:** macOS with Xcode CLI tools, [Homebrew](https://brew.sh), and Fastlane (`brew install fastlane`)

### 1. Install the Skill

**Global Install** (available in all projects)

In Claude Code:
```
/plugin marketplace add greenstevester/fastlane-skill
```

Or via terminal:
```bash
curl -o ~/.claude/commands/setup-fastlane.md \
  https://raw.githubusercontent.com/greenstevester/fastlane-skill/main/skills/setup-fastlane.md
```

**Project-Only Install** (available only in current project)
```bash
mkdir -p .claude/commands
curl -o .claude/commands/setup-fastlane.md \
  https://raw.githubusercontent.com/greenstevester/fastlane-skill/main/skills/setup-fastlane.md
```

### 2. Run It

Navigate to your iOS/macOS project and run:

```
/setup-fastlane
```

### 3. Verify

```bash
fastlane lanes   # Should list: test, beta, release, metadata, screenshots, sync_signing
```

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
| No Xcode project detected | Run from directory containing `.xcodeproj` |
| Bundle ID not found | Ensure project has `PRODUCT_BUNDLE_IDENTIFIER` set |
| Fastlane not found | Run `brew install fastlane` |

## Contributing

Issues and PRs welcome at [github.com/greenstevester/fastlane-skill](https://github.com/greenstevester/fastlane-skill).

## License

MIT
