<p align="center">
  <img src="icon.png" alt="Fastlane Skill Icon" width="128" height="128">
</p>

# Fastlane Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-purple.svg)](https://claude.ai/code)
[![Fastlane](https://img.shields.io/badge/Fastlane-00F200?logo=fastlane&logoColor=white)](https://fastlane.tools/)

> **From zero to App Store in natural language.** Just tell Claude what you need.

## Why Fastlane?

[Fastlane](https://fastlane.tools) is the industry-standard automation tool for iOS and Android deployment, trusted by companies like Google, Uber, and Airbnb.

**What it does:**
- 🚀 Automates screenshots, beta deployment, App Store releases, and code signing
- ⏱️ Turns hours of manual work into single commands
- 🔄 Ensures consistent, reproducible releases every time

**Battle-tested:**
- 40,000+ GitHub stars
- 6,000+ forks
- 1,000+ contributors
- Used by millions of apps worldwide

This skill brings Fastlane's power to Claude Code—set up everything through natural conversation.

## Prerequisites

- macOS with Xcode CLI tools
- [Homebrew](https://brew.sh)
- Fastlane: `brew install fastlane`

## Quick Start

```
/plugin marketplace add greenstevester/fastlane-skill
```
Restart Claude Code.

**Verify:** Ask Claude "What Fastlane skills do you have?"

## Usage

Navigate to your iOS/macOS project and ask Claude naturally:

### Initial Setup
> "Set up Fastlane for this project"

Creates `Appfile`, `Fastfile`, lanes, and metadata structure by introspecting your Xcode project.

### TestFlight Beta
> "Upload this app to TestFlight"

Syncs certificates, increments build number, builds, and uploads.

### App Store Release
> "Submit to the App Store"

Submits your tested TestFlight build for App Store review.

### Code Signing
> "Set up Match for code signing"

Configures certificate sharing via private Git repo. No more "works on my machine."

### Screenshots
> "Automate App Store screenshots"

Sets up Snapshot to capture screenshots across all device sizes and languages.

## What You Get

| Skill | What It Does | Time Saved | Docs |
|-------|-------------|------------|------|
| `setup-fastlane` | Complete Fastlane config from Xcode project | 2-3 hours | [→](skills/setup-fastlane/SKILL.md) |
| `beta` | One command TestFlight uploads | 30 min/release | [→](skills/beta/SKILL.md) |
| `release` | App Store submission workflow | 1 hour | [→](skills/release/SKILL.md) |
| `match` | Team code signing setup | 4-6 hours | [→](skills/match/SKILL.md) |
| `snapshot` | Automated screenshots (50+ images) | 3-4 hours | [→](skills/snapshot/SKILL.md) |

## After Setup

```bash
# Run your new lanes
fastlane lanes              # See all available lanes
fastlane ios test           # Run tests
fastlane ios beta           # Upload to TestFlight
fastlane ios release        # Submit to App Store

# Manage metadata
fastlane deliver download_metadata
fastlane deliver download_screenshots
```

## Update

```
/plugin marketplace update fastlane-skill
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Skills not loading | Restart Claude Code after install |
| No Xcode project | Run from directory with `.xcodeproj` or `.xcworkspace` |
| Code signing errors | Ask Claude: "Set up Match for code signing" |

## Local Development

```bash
claude --plugin-dir /path/to/fastlane-skill
```

## License

MIT - [github.com/greenstevester/fastlane-skill](https://github.com/greenstevester/fastlane-skill)
