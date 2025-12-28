---
description: Set up Fastlane for iOS/macOS app automation
argument-hint: [project-path]
allowed-tools: Bash, Read, Write, Edit, Glob
---

## Set Up Fastlane for iOS/macOS Automation

I'll set up Fastlane for your iOS/macOS project with full App Store distribution support.

### Current Environment Check
- Xcode CLI Tools: !`xcode-select -p 2>/dev/null && echo "✓ Installed" || echo "✗ Not installed"`
- Homebrew: !`brew --version 2>/dev/null | head -1 || echo "✗ Not installed"`
- Fastlane: !`fastlane --version 2>/dev/null | grep "fastlane " | head -1 || echo "✗ Not installed"`
- Existing Fastlane config: !`ls -la fastlane/ 2>/dev/null | head -3 || echo "No fastlane directory"`

### App Introspection
- Xcode projects: !`find . -maxdepth 3 \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) 2>/dev/null | head -5`
- Bundle ID: !`grep -r "PRODUCT_BUNDLE_IDENTIFIER" --include="*.pbxproj" . 2>/dev/null | head -1 | sed 's/.*= //' | tr -d '";'`
- App Version: !`grep -r "MARKETING_VERSION" --include="*.pbxproj" . 2>/dev/null | head -1 | sed 's/.*= //' | tr -d '";'`
- Team ID: !`grep -r "DEVELOPMENT_TEAM" --include="*.pbxproj" . 2>/dev/null | head -1 | sed 's/.*= //' | tr -d '";'`

### Target Project: ${ARGUMENTS:-auto-detect}

---

## What This Skill Sets Up

1. **Fastlane installation** via Homebrew
2. **App configuration** - Appfile with introspected bundle ID, team ID
3. **Lane definitions** - test, beta, release lanes
4. **App Store metadata** - deliver metadata folder structure
5. **Xcode Cloud integration** (optional) - ci_scripts for automated deployment

---

## Step 1: Install Prerequisites

**Xcode Command Line Tools** (if not installed):
```bash
xcode-select --install
```

**Homebrew** (if not installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Fastlane**:
```bash
brew install fastlane
```

---

## Step 2: Create Fastlane Configuration

### `fastlane/Appfile`
Populated with introspected values from your Xcode project:
```ruby
app_identifier("{{BUNDLE_ID}}")      # From PRODUCT_BUNDLE_IDENTIFIER
apple_id("{{APPLE_ID}}")             # Your Apple ID email
team_id("{{TEAM_ID}}")               # From DEVELOPMENT_TEAM
itc_team_id("{{ITC_TEAM_ID}}")       # App Store Connect team (if different)
```

### `fastlane/Fastfile`
Complete lane definitions:
```ruby
default_platform(:ios)

platform :ios do
  desc "Run all tests"
  lane :test do
    scan(scheme: "{{SCHEME}}")
  end

  desc "Build for TestFlight (Beta)"
  lane :beta do
    increment_build_number
    gym(scheme: "{{SCHEME}}", export_method: "app-store")
    pilot(skip_waiting_for_build_processing: true)
  end

  desc "Build and release to App Store"
  lane :release do
    increment_build_number
    gym(scheme: "{{SCHEME}}", export_method: "app-store")
    deliver(
      submit_for_review: false,
      automatic_release: false,
      force: true
    )
  end

  desc "Update App Store metadata only (no build)"
  lane :metadata do
    deliver(
      skip_binary_upload: true,
      skip_screenshots: true,
      force: true
    )
  end

  desc "Upload screenshots to App Store"
  lane :screenshots do
    snapshot(scheme: "{{SCHEME}}UITests")
    deliver(
      skip_binary_upload: true,
      skip_metadata: true,
      force: true
    )
  end

  desc "Sync code signing with match"
  lane :sync_signing do
    match(type: "development")
    match(type: "appstore")
  end
end
```

---

## Step 3: Set Up App Store Metadata (deliver)

Create the metadata folder structure for `fastlane deliver`:

```
fastlane/
├── metadata/
│   ├── en-US/
│   │   ├── name.txt                    # App name
│   │   ├── subtitle.txt                # App subtitle
│   │   ├── description.txt             # Full description
│   │   ├── keywords.txt                # Search keywords (comma-separated)
│   │   ├── release_notes.txt           # What's New text
│   │   ├── promotional_text.txt        # Promotional text
│   │   ├── support_url.txt             # Support URL
│   │   ├── marketing_url.txt           # Marketing URL
│   │   └── privacy_url.txt             # Privacy policy URL
│   ├── copyright.txt                   # Copyright notice
│   ├── primary_category.txt            # Primary category
│   └── secondary_category.txt          # Secondary category
├── screenshots/
│   └── en-US/
│       ├── iPhone 6.5/                 # iPhone 15 Pro Max screenshots
│       ├── iPhone 5.5/                 # iPhone 8 Plus screenshots
│       └── iPad Pro 12.9/              # iPad screenshots
└── review_information/
    ├── demo_user.txt                   # Demo account username
    ├── demo_password.txt               # Demo account password
    └── notes.txt                       # Notes for App Review
```

**Initialize metadata from existing App Store listing:**
```bash
fastlane deliver download_metadata
fastlane deliver download_screenshots
```

**Push metadata to App Store Connect:**
```bash
fastlane deliver              # Upload metadata + binary
fastlane metadata             # Metadata only (no build)
```

---

## Step 4: Xcode Cloud Integration (Optional)

For Xcode Cloud + Fastlane, create a post-build script that runs Fastlane after successful builds.

### `ci_scripts/ci_post_xcodebuild.sh`
```bash
#!/bin/bash
set -e

# Only run on archive builds
if [[ "$CI_XCODEBUILD_ACTION" != "archive" ]]; then
    echo "Skipping Fastlane - not an archive build"
    exit 0
fi

# Install Fastlane if not present
if ! command -v fastlane &> /dev/null; then
    brew install fastlane
fi

# Navigate to project root
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Run based on workflow
case "$CI_WORKFLOW" in
    "Beta")
        fastlane ios beta
        ;;
    "Release")
        fastlane ios release
        ;;
    "Metadata")
        fastlane ios metadata
        ;;
    *)
        echo "Unknown workflow: $CI_WORKFLOW"
        ;;
esac
```

### `ci_scripts/ci_post_clone.sh` (for dependencies)
```bash
#!/bin/bash
set -e

# Install Homebrew (required for Fastlane)
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Fastlane
brew install fastlane
```

**Make scripts executable:**
```bash
chmod +x ci_scripts/*.sh
```

---

## Step 5: Configure App Store Connect API Key (Recommended for CI)

For automated deployments, use an API key instead of Apple ID credentials:

1. Generate key at [App Store Connect > Users and Access > Keys](https://appstoreconnect.apple.com/access/api)
2. Create `fastlane/api_key.json`:
```json
{
  "key_id": "ABC123",
  "issuer_id": "xyz-xyz-xyz",
  "key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----",
  "in_house": false
}
```

3. Add to `.gitignore`:
```
fastlane/api_key.json
```

4. Reference in Fastfile:
```ruby
lane :beta do
  api_key = app_store_connect_api_key(
    key_id: "ABC123",
    issuer_id: "xyz-xyz-xyz",
    key_filepath: "fastlane/api_key.json"
  )
  pilot(api_key: api_key)
end
```

---

## Usage Summary

```bash
# Development
fastlane ios test              # Run tests
fastlane ios sync_signing      # Sync certificates

# Distribution
fastlane ios beta              # Build + TestFlight
fastlane ios release           # Build + App Store

# Metadata only (no build)
fastlane ios metadata          # Update App Store listing
fastlane ios screenshots       # Upload screenshots

# Download existing metadata
fastlane deliver download_metadata
fastlane deliver download_screenshots
```

---

## Files to Commit

```
fastlane/
├── Appfile
├── Fastfile
├── metadata/          # App Store listing text
└── screenshots/       # App Store screenshots

ci_scripts/            # Xcode Cloud integration (optional)
├── ci_post_clone.sh
└── ci_post_xcodebuild.sh

Gemfile                # For CI reproducibility (optional)
```

**Do NOT commit:**
- `fastlane/api_key.json` (contains secrets)
- `fastlane/report.xml` (build artifacts)
