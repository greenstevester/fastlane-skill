# Fastlane Skill for Claude Code

A Claude Code skill that sets up [Fastlane](https://fastlane.tools/) for iOS/macOS app automation.

## What This Skill Does

- Checks your environment (Xcode CLI tools, Homebrew, existing Fastlane setup)
- Installs Fastlane via Homebrew (recommended for macOS)
- Creates `fastlane/Appfile` and `fastlane/Fastfile` with common lanes
- Configures lanes for testing, TestFlight, and App Store deployment

## Installation

### Option 1: Plugin Marketplace (Recommended)

```bash
# In Claude Code, run:
/plugin marketplace add greenstevester/fastlane-skill
/plugin install setup-fastlane@fastlane-skill
```

### Option 2: Manual Installation

Download the skill directly to your Claude commands folder:

```bash
curl -o ~/.claude/commands/setup-fastlane.md \
  https://raw.githubusercontent.com/greenstevester/fastlane-skill/main/skills/setup-fastlane.md
```

## Usage

Once installed, run in Claude Code:

```
/setup-fastlane
```

Or with a specific project path:

```
/setup-fastlane ./path/to/ios/project
```

## Prerequisites

- macOS
- Xcode Command Line Tools (`xcode-select --install`)
- Homebrew (`brew.sh`)

## What Gets Created

| File | Purpose |
|------|---------|
| `fastlane/Appfile` | App metadata (bundle ID, team ID) |
| `fastlane/Fastfile` | Lane definitions |
| `Gemfile` (optional) | For CI/CD reproducibility |

## Available Lanes

After setup, you'll have these lanes:

```bash
fastlane ios test      # Run tests
fastlane ios beta      # Build and upload to TestFlight
fastlane ios release   # Build and upload to App Store
```

## Why Homebrew?

This skill uses Homebrew to install Fastlane because:

1. **Ruby Compatibility**: Ruby 4.0 (Dec 2024) has compatibility issues with Fastlane's Bundler requirements. Homebrew's Fastlane bundles a compatible Ruby.
2. **Simplicity**: No need to manage Ruby versions or gems manually.
3. **Easy Updates**: Just run `brew upgrade fastlane`.

## Contributing

Issues and PRs welcome at [github.com/greenstevester/fastlane-skill](https://github.com/greenstevester/fastlane-skill).

## License

MIT
