# Xcode Cloud Integration (GitHub)

This guide explains how to connect your GitHub repository to Xcode Cloud and run Fastlane lanes automatically after builds.

## Overview

The skill creates `ci_scripts/` that run Fastlane after Xcode Cloud builds:

| Script | When It Runs | Purpose |
|--------|--------------|---------|
| `ci_post_clone.sh` | After repo clone | Installs Homebrew + Fastlane |
| `ci_post_xcodebuild.sh` | After successful archive | Runs Fastlane lane based on workflow name |

## Setup Steps

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

### 4. Add App Store Connect API Key

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

## Troubleshooting

### Build succeeds but Fastlane doesn't run
- Ensure workflow name is exactly `Beta`, `Release`, or `Metadata` (case-sensitive)
- Check that `ci_post_xcodebuild.sh` is executable (`chmod +x`)

### API key authentication fails
- Verify the private key is base64 encoded: `base64 -i AuthKey_XXX.p8 | tr -d '\n'`
- Ensure `is_key_content_base64: true` is set in your Fastfile

### Homebrew installation fails
- Xcode Cloud runs on both Intel and Apple Silicon Macs
- The `ci_post_clone.sh` script handles both architectures automatically
