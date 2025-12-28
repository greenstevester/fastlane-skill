# Fastlane Skill for Claude Code

A Claude Code skill that sets up [Fastlane](https://fastlane.tools/) for complete iOS/macOS app automation and App Store distribution.

## What This Skill Does

- **Introspects your Xcode project** - Extracts bundle ID, version, team ID automatically
- **Configures Fastlane** - Creates Appfile, Fastfile with common lanes
- **Sets up App Store metadata** - Full `deliver` folder structure for managing App Store listing from text files
- **Xcode Cloud integration** - Optional ci_scripts for automated deployment
- **API key setup** - Guidance for CI/CD authentication

### Supported Workflows

| Lane | Description |
|------|-------------|
| `test` | Run unit tests |
| `beta` | Build + upload to TestFlight |
| `release` | Build + upload to App Store |
| `metadata` | Update App Store listing (no build) |
| `screenshots` | Upload screenshots to App Store |
| `sync_signing` | Sync certificates with match |

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

## What Gets Created

```
fastlane/
├── Appfile                    # App config (bundle ID, team ID)
├── Fastfile                   # Lane definitions
├── metadata/
│   ├── en-US/
│   │   ├── name.txt           # App name
│   │   ├── subtitle.txt       # App subtitle
│   │   ├── description.txt    # Full description
│   │   ├── keywords.txt       # Search keywords
│   │   ├── release_notes.txt  # What's New
│   │   └── ...                # URLs, promotional text
│   ├── copyright.txt
│   ├── primary_category.txt
│   └── secondary_category.txt
├── screenshots/
│   └── en-US/
│       ├── iPhone 6.5/        # iPhone 15 Pro Max
│       ├── iPhone 5.5/        # iPhone 8 Plus
│       └── iPad Pro 12.9/     # iPad
└── review_information/
    ├── demo_user.txt          # Demo account for review
    └── notes.txt              # Notes for App Review

ci_scripts/                    # Xcode Cloud (optional)
├── ci_post_clone.sh           # Install dependencies
└── ci_post_xcodebuild.sh      # Run Fastlane after build
```

## App Store Metadata Management

The skill sets up `fastlane deliver` for managing your App Store listing from version-controlled text files:

```bash
# Download existing metadata from App Store Connect
fastlane deliver download_metadata
fastlane deliver download_screenshots

# Push metadata to App Store Connect
fastlane ios metadata          # Update listing (no build)
fastlane deliver               # Full upload with binary
```

Edit files in `fastlane/metadata/en-US/` and commit them to git for versioned App Store listings.

## Xcode Cloud Integration

For Xcode Cloud + Fastlane, the skill creates `ci_scripts/` that run Fastlane after successful builds:

1. **ci_post_clone.sh** - Installs Homebrew and Fastlane
2. **ci_post_xcodebuild.sh** - Runs appropriate lane based on workflow name

Configure Xcode Cloud workflows named "Beta", "Release", or "Metadata" to trigger the corresponding Fastlane lane.

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
