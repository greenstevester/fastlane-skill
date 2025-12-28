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

## Xcode Cloud Integration (GitHub)

The skill creates `ci_scripts/` that run Fastlane after Xcode Cloud builds. Here's how to set it up with a GitHub repository:

### 1. Connect GitHub to Xcode Cloud

1. Open your project in Xcode
2. Go to **Product → Xcode Cloud → Create Workflow**
3. Sign in to App Store Connect when prompted
4. Select **Grant Access to GitHub** and authorize your repository
5. Xcode will detect your repo and guide you through initial setup

### 2. Prepare Your Repository

Ensure `ci_scripts/` is at your repo root (same level as `.xcodeproj`):

```
your-repo/
├── YourApp.xcodeproj
├── ci_scripts/
│   ├── ci_post_clone.sh
│   └── ci_post_xcodebuild.sh
└── fastlane/
    ├── Appfile
    └── Fastfile
```

Make scripts executable before committing:
```bash
chmod +x ci_scripts/*.sh
git add ci_scripts/
git commit -m "Add Xcode Cloud scripts"
git push
```

### 3. Create Workflows in Xcode Cloud

In Xcode, go to **Product → Xcode Cloud → Manage Workflows** and create workflows with these exact names:

| Workflow Name | Trigger | What It Does |
|---------------|---------|--------------|
| `Beta` | Push to `develop` or manual | Build → TestFlight |
| `Release` | Push to `main` or manual | Build → App Store |
| `Metadata` | Manual only | Update App Store listing (no build) |

The `ci_post_xcodebuild.sh` script matches the workflow name to run the corresponding Fastlane lane.

### 4. Add App Store Connect API Key (Required for CI)

Xcode Cloud needs an API key to upload to TestFlight/App Store:

1. Generate a key at [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api)
2. In Xcode Cloud workflow settings, add these **Environment Variables**:

   | Variable | Value |
   |----------|-------|
   | `APP_STORE_CONNECT_API_KEY_KEY_ID` | Your Key ID (e.g., `ABC123`) |
   | `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | Your Issuer ID |
   | `APP_STORE_CONNECT_API_KEY_KEY` | The private key contents (base64 encoded) |

3. Mark all as **Secret** to hide values in logs

4. Update your `Fastfile` to use the API key:
   ```ruby
   lane :beta do
     api_key = app_store_connect_api_key(
       key_id: ENV["APP_STORE_CONNECT_API_KEY_KEY_ID"],
       issuer_id: ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"],
       key: ENV["APP_STORE_CONNECT_API_KEY_KEY"],
       is_key_content_base64: true
     )
     pilot(api_key: api_key)
   end
   ```

### 5. Configure Branch Triggers

In each workflow's **Start Conditions**:

- **Beta workflow**: Start on push to `develop` branch
- **Release workflow**: Start on push to `main` branch (or tag pattern like `v*`)
- **Metadata workflow**: Manual start only

### What the Scripts Do

| Script | When It Runs | Purpose |
|--------|--------------|---------|
| `ci_post_clone.sh` | After repo clone | Installs Homebrew + Fastlane |
| `ci_post_xcodebuild.sh` | After successful archive | Runs Fastlane lane based on workflow name |

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
