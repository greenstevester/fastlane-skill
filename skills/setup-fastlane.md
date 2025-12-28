---
description: Set up Fastlane for iOS/macOS app automation
argument-hint: [project-path]
allowed-tools: Bash, Read, Write, Edit, Glob
---

## Set Up Fastlane for iOS/macOS Automation

I'll set up Fastlane for your iOS/macOS project using Homebrew (recommended for macOS).

### Current Environment Check
- Xcode CLI Tools: !`xcode-select -p 2>/dev/null && echo "✓ Installed" || echo "✗ Not installed"`
- Homebrew: !`brew --version 2>/dev/null | head -1 || echo "✗ Not installed"`
- Fastlane: !`fastlane --version 2>/dev/null | grep "fastlane " | head -1 || echo "✗ Not installed"`
- Existing Fastlane config: !`ls -la fastlane/ 2>/dev/null | head -3 || echo "No fastlane directory"`
- Xcode projects: !`find . -maxdepth 3 -name "*.xcodeproj" -o -name "*.xcworkspace" 2>/dev/null | head -5 || echo "None found"`

### Target Project: ${ARGUMENTS:-auto-detect}

---

## Installation Steps

### 1. Install Prerequisites

**Xcode Command Line Tools** (if not installed):
```bash
xcode-select --install
```

**Homebrew** (if not installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Fastlane via Homebrew

```bash
brew install fastlane
```

**Why Homebrew?**
- Bundles compatible Ruby version (avoids Ruby 4.0 compatibility issues)
- Simpler than managing Ruby gems manually
- Easy updates: `brew upgrade fastlane`

### 3. Create Fastlane Configuration

Create `fastlane/` directory with:

**`fastlane/Appfile`** - App metadata:
```ruby
app_identifier("com.company.appname")  # Bundle ID
# team_id("TEAM_ID")                   # Apple Developer Team ID
# apple_id("email@example.com")        # Your Apple ID
```

**`fastlane/Fastfile`** - Lane definitions:
```ruby
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan(scheme: "YourScheme")
  end

  desc "Build for TestFlight"
  lane :beta do
    increment_build_number
    gym(scheme: "YourScheme", export_method: "app-store")
    pilot(skip_waiting_for_build_processing: true)
  end

  desc "Release to App Store"
  lane :release do
    increment_build_number
    gym(scheme: "YourScheme", export_method: "app-store")
    deliver(submit_for_review: false, force: true)
  end
end
```

### 4. Optional: Create Gemfile for CI/CD

For reproducible builds in CI environments:

```ruby
source "https://rubygems.org"
gem "fastlane"
```

Then run with `bundle exec fastlane [lane]` in CI.

---

## Usage

```bash
fastlane lanes              # List all available lanes
fastlane ios test           # Run tests
fastlane ios beta           # Build and upload to TestFlight
fastlane ios release        # Build and upload to App Store
```

## Common Additional Lanes

- `sync_signing` - Certificate management with `match`
- `screenshots` - Automated App Store screenshots
- `build` - Debug builds for local testing

## Files to Commit

- `fastlane/Fastfile`
- `fastlane/Appfile`
- `Gemfile` and `Gemfile.lock` (if using Bundler for CI)

## Next Steps

1. Update `Appfile` with your bundle ID and team info
2. Set up code signing with `fastlane match init`
3. Configure App Store Connect API key for CI/CD
