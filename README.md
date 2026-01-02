<p align="center">
  <img src="icon.png" alt="Fastlane Skill Icon" width="128" height="128">
</p>

# Fastlane Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-purple.svg)](https://claude.ai/code)
[![Fastlane](https://img.shields.io/badge/Fastlane-00F200?logo=fastlane&logoColor=white)](https://fastlane.tools/)

> **From zero to App Store in natural language.** Let Claude do the heavy lifting.

## Why Fastlane?

[Fastlane](https://fastlane.tools) is the industry-standard automation tool for iOS and Android deployment, trusted by companies like Google, Uber, and Airbnb.

**Fastlane:**
- Automates screenshots, beta deployment, App Store releases, and code signing
- Turns hours of manual work into single commands
- Ensures consistent, reproducible releases every time
- 40,000+ GitHub stars
- 6,000+ forks
- 1,000+ contributors
- Used by millions of apps worldwide

_Before Fastlane, releasing an app to Apple was like trying to get through airport security with a bottle of water and a sense of optimism. I can only imagine that everyone who contributed to Fastlane, were also wondering why Apple thought uploading 47 screenshots in 12 languages by hand, was somehow an elegantly designed "dev-friendly" workflow. I wish Jonny Ive was also involved in the engine room on software development life-cycles, where he would have shouted down the maze of activities needed to just ship a new version of your app._

Anyway, BIG Kudos to all the Fastlane [contributors](https://github.com/fastlane/fastlane/graphs/contributors) tho, who saved us all from the joy of manually uploading screenshots at 2am.

## Why This Skill?

Fastlane is powerful—but **you** need to read the docs to use it correctly.

**Here, we invert this:** Claude already read the docs, knows how to use it correctly, and **you** just use the skill and profit.

| Without This Skill | With This Skill |
|--------------------|-----------------|
| Read docs for hours | Ask in plain English |
| Manually find bundle ID, team ID | Auto-detected from Xcode |
| Copy/paste config templates | Generated and customized for you |
| Debug cryptic Ruby errors | Guided troubleshooting |
| Learn Fastlane syntax | Just describe what you want |

**Key benefits:**
- **Zero learning curve** - No Fastlane expertise required
- **Smart introspection** - Reads your Xcode project, not you
- **Best practices built-in** - Homebrew install, proper lane structure
- **Conversational setup** - Iterate and adjust through chat

> **Note:** Currently tested for iOS/macOS targets. Android support coming soon.

## Prerequisites

- macOS with Xcode CLI tools
- [Homebrew](https://brew.sh)
- Fastlane: `brew install fastlane`

## Installation

```
/plugin marketplace add greenstevester/fastlane-skill
```
Restart Claude Code.

**Verify:** Ask Claude "What Fastlane skills do you have?"

## Usage

Navigate to your iOS/macOS project and ask Claude naturally:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            App Release Workflow                             │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
  │  SETUP   │───▶│  CERTS   │───▶│  SCREENS │───▶│   BETA   │───▶│ RELEASE  │
  └──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
       │               │               │               │               │
       ▼               ▼               ▼               ▼               ▼
  "Set up         "Set up Match    "Automate       "Upload to      "Submit to
   Fastlane"       for code         App Store       TestFlight"     the App
                   signing"         screenshots"                    Store"
```

| Step | What Claude Does |
|------|------------------|
| **Setup** | Creates `Appfile`, `Fastfile`, lanes from your Xcode project |
| **Certs** | Configures Match for team certificate sharing via private Git repo |
| **Screens** | Sets up Snapshot for automated screenshots across devices/languages |
| **Beta** | Syncs certs, increments build, builds, uploads to TestFlight |
| **Release** | Submits your tested TestFlight build for App Store review |

## What You Get

| Skill | What It Does | Time Saved | Docs |
|-------|-------------|------------|------|
| `setup-fastlane` | Complete Fastlane config from Xcode project | 2-3 hours | [→](skills/setup-fastlane/SKILL.md) |
| `beta` | One command TestFlight uploads | 30 min/release | [→](skills/beta/SKILL.md) |
| `release` | App Store submission workflow | 1 hour | [→](skills/release/SKILL.md) |
| `match` | Team code signing setup | 4-6 hours | [→](skills/match/SKILL.md) |
| `snapshot` | Automated screenshots (50+ images) | 3-4 hours | [→](skills/snapshot/SKILL.md) |

## After Setup

**Fastlane** (obviously from its name) has a concept of **lanes**—automated workflows defined in your `Fastfile`. Each lane bundles multiple actions into a single command:

```
┌─────────────────────────────────────────────────────────────────┐
│  Lane: "beta"                                                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐        │
│  │  sync   │──▶│increment│──▶│  build  │──▶│ upload  │        │
│  │  certs  │   │ version │   │   app   │   │TestFlight│       │
│  └─────────┘   └─────────┘   └─────────┘   └─────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
                    fastlane ios beta   ◀── One command runs all steps
```

**Run your lanes:**
```bash
fastlane lanes              # See all available lanes
fastlane ios test           # Run tests
fastlane ios beta           # Upload to TestFlight
fastlane ios release        # Submit to App Store
```

**Manage metadata:**
```bash
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
