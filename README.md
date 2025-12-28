# Fastlane Skill for Claude Code

A Claude Code skill that sets up [Fastlane](https://fastlane.tools/) for iOS/macOS app automation.

## What This Skill Does

- Checks your environment (Xcode CLI tools, Homebrew, existing Fastlane setup)
- Installs Fastlane via Homebrew (recommended for macOS)
- Creates `fastlane/Appfile` and `fastlane/Fastfile` with common lanes
- Configures lanes for testing, TestFlight, and App Store deployment

## Quick Start

### 1. Install Dependencies (one-time setup)

```bash
# Xcode Command Line Tools
xcode-select --install

# Homebrew (if not installed) - see https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Fastlane
brew install fastlane
```

### 2. Install the Skill

**Option A: Plugin Marketplace (Recommended)**
```
/plugin marketplace add greenstevester/fastlane-skill
/plugin install setup-fastlane@fastlane-skill
```

**Option B: Manual Download**
```bash
curl -o ~/.claude/commands/setup-fastlane.md \
  https://raw.githubusercontent.com/greenstevester/fastlane-skill/main/skills/setup-fastlane.md
```

### 3. Run It

Navigate to your iOS/macOS project directory and run:

```
/setup-fastlane
```

Or specify a project path:

```
/setup-fastlane ./path/to/ios/project
```

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

## Requirements

| Dependency | Install Command | Notes |
|------------|-----------------|-------|
| macOS | - | Required for Xcode |
| Xcode CLI Tools | `xcode-select --install` | Build tools |
| Homebrew | See [brew.sh](https://brew.sh) | Package manager |
| Fastlane | `brew install fastlane` | iOS automation |

## Why Homebrew for Fastlane?

This skill uses Homebrew to install Fastlane because:

1. **Ruby Compatibility**: Ruby 4.0 (Dec 2024) has compatibility issues with Fastlane's Bundler requirements. Homebrew's Fastlane bundles a compatible Ruby.
2. **Simplicity**: No need to manage Ruby versions or gems manually.
3. **Easy Updates**: Just run `brew upgrade fastlane`.

## Contributing

Issues and PRs welcome at [github.com/greenstevester/fastlane-skill](https://github.com/greenstevester/fastlane-skill).

## License

MIT
