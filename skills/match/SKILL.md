---
description: Set up Match for iOS code signing certificate management
argument-hint: [--readonly] [--type development|appstore|adhoc]
allowed-tools: Bash, Read, Write, Edit
---

## Code Signing with Match

Set up Fastlane Match to manage iOS code signing certificates and provisioning profiles in a shared Git repository.

### Pre-flight Checks
- Fastlane installed: !`fastlane --version 2>/dev/null | grep "fastlane " | head -1 || echo "✗ Not installed - run: brew install fastlane"`
- Fastfile exists: !`ls fastlane/Fastfile 2>/dev/null && echo "✓ Found" || echo "✗ Not found - run /setup-fastlane first"`
- Existing Matchfile: !`ls fastlane/Matchfile 2>/dev/null && echo "✓ Already configured" || echo "○ Not configured yet"`
- Git available: !`git --version 2>/dev/null | head -1 || echo "✗ Git not installed"`

### Arguments: ${ARGUMENTS:-setup}

---

## What is Match?

Match stores your iOS certificates and provisioning profiles in a **private Git repository**, encrypted with a passphrase. Benefits:

- **Team sharing**: Everyone uses the same certificates (no more "works on my machine")
- **CI/CD ready**: Clone the repo in your pipeline, no manual cert management
- **Revoke protection**: Prevents accidental certificate revocation
- **Audit trail**: Git history shows who changed what and when

---

## Step 1: Create a Private Git Repository

Create a **private** repository to store your encrypted certificates:

```bash
# GitHub CLI (recommended)
gh repo create certificates --private --clone
cd certificates && cd ..

# Or manually at github.com/new (select Private)
```

**Repository naming conventions:**
- `certificates` or `ios-certificates`
- `fastlane-certs`
- `{company}-signing`

> **Security**: This repo will contain encrypted certificates. Keep it private and limit access to team members who need to build the app.

---

## Step 2: Initialize Match

Run match init to create your Matchfile:

```bash
fastlane match init
```

When prompted:
1. **Storage mode**: Select `git`
2. **Git URL**: Enter your private repo URL (e.g., `git@github.com:yourorg/certificates.git`)

This creates `fastlane/Matchfile`:

```ruby
git_url("git@github.com:yourorg/certificates.git")

storage_mode("git")

type("development") # Default type, can be overridden per-lane

# app_identifier(["com.yourcompany.app"])  # Optional: limit to specific apps
# username("user@example.com")              # Optional: Apple ID
```

---

## Step 3: Generate Certificates

Generate certificates for each distribution type:

### Development (for debugging on devices)
```bash
fastlane match development
```

### App Store (for TestFlight and App Store)
```bash
fastlane match appstore
```

### Ad Hoc (for direct device distribution)
```bash
fastlane match adhoc
```

**First run prompts:**
1. **Apple ID**: Your Apple Developer account email
2. **Passphrase**: Create a strong passphrase to encrypt certificates (save this securely!)

> **Important**: Save the passphrase in a password manager. You'll need it for CI/CD and new team members.

---

## Step 4: Integrate with Fastfile

Update your lanes to use Match before building:

```ruby
default_platform(:ios)

platform :ios do
  desc "Sync all certificates"
  lane :sync_signing do
    match(type: "development")
    match(type: "appstore")
  end

  desc "Build for TestFlight"
  lane :beta do |options|
    match(type: "appstore", readonly: true)
    increment_build_number unless options[:skip_build_increment]
    gym(scheme: "YourApp", export_method: "app-store")
    pilot(skip_waiting_for_build_processing: true)
  end

  desc "Build for App Store"
  lane :release do
    match(type: "appstore", readonly: true)
    increment_build_number
    gym(scheme: "YourApp", export_method: "app-store")
    deliver(submit_for_review: false, force: true)
  end
end
```

**Key pattern**: Use `readonly: true` in build lanes to prevent accidental certificate regeneration.

---

## Step 5: Onboard Team Members

New team members run:

```bash
# Clone and decrypt existing certificates (readonly)
fastlane match development --readonly
fastlane match appstore --readonly
```

They'll need:
1. Access to the private certificates repository
2. The Match passphrase
3. Apple Developer team membership

**Readonly mode** ensures they can't accidentally revoke or regenerate certificates.

---

## Step 6: CI/CD Setup

Set these environment variables in your CI/CD system:

```bash
# Required
MATCH_PASSWORD="your-match-passphrase"
MATCH_GIT_URL="git@github.com:yourorg/certificates.git"

# For App Store Connect (choose one method)
# Method 1: App-specific password
FASTLANE_USER="your@appleid.com"
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"

# Method 2: API Key (recommended for CI)
APP_STORE_CONNECT_API_KEY_ID="ABC123"
APP_STORE_CONNECT_API_KEY_ISSUER_ID="xyz-xyz-xyz"
APP_STORE_CONNECT_API_KEY_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
```

### GitHub Actions Example

```yaml
- name: Install certificates
  run: fastlane match appstore --readonly
  env:
    MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
    MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
```

### Xcode Cloud

Add to `ci_scripts/ci_post_clone.sh`:
```bash
# Install Fastlane and sync certificates
brew install fastlane
fastlane match appstore --readonly
```

Set `MATCH_PASSWORD` in Xcode Cloud environment variables.

---

## Troubleshooting

### "Couldn't decrypt the repo"
Wrong passphrase. Verify `MATCH_PASSWORD` is correct.

### "Code signing error: No provisioning profiles"
Run `fastlane match appstore` (without `--readonly`) to generate profiles.

### "Your certificate has been revoked"
Someone revoked certs in Apple Developer portal. Regenerate:
```bash
fastlane match nuke development  # Removes all development certs
fastlane match development       # Regenerates
```

### "Multiple teams found"
Specify team in Matchfile:
```ruby
team_id("ABCD1234")
```

### "Unable to find app with bundle identifier"
Register the app first:
```bash
fastlane produce create -a com.yourcompany.app -n "Your App Name"
```

---

## Match Commands Reference

```bash
# Setup
fastlane match init                    # Create Matchfile
fastlane match development             # Generate dev certs
fastlane match appstore                # Generate App Store certs
fastlane match adhoc                   # Generate Ad Hoc certs

# Team use (readonly - won't modify certs)
fastlane match development --readonly
fastlane match appstore --readonly

# Maintenance
fastlane match nuke development        # Revoke all dev certs
fastlane match nuke distribution       # Revoke all dist certs
fastlane match change_password         # Change encryption passphrase

# Debugging
fastlane match development --verbose   # Detailed output
```

---

## Security Best Practices

1. **Private repository**: Never make the certificates repo public
2. **Strong passphrase**: Use 20+ characters, store in password manager
3. **Limit access**: Only team members who build should have repo access
4. **Rotate periodically**: Change passphrase annually with `match change_password`
5. **API keys over passwords**: Use App Store Connect API keys for CI/CD

---

## Files Created

```
fastlane/
└── Matchfile          # Match configuration

# In your certificates repo:
certs/
├── development/       # Development certificates
└── distribution/      # App Store/Ad Hoc certificates
profiles/
├── development/       # Development provisioning profiles
├── appstore/          # App Store provisioning profiles
└── adhoc/             # Ad Hoc provisioning profiles
```
