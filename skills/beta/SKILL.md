---
name: beta
description: Build and upload iOS app to TestFlight
argument-hint: [skip_build_increment:true] [changelog:"text"]
allowed-tools: Bash, Read
---

## TestFlight Beta Release

Build and upload the iOS app to TestFlight for beta testing.

### Pre-flight Checks
- Fastlane: !`if grep -qE "^[[:space:]]*gem[[:space:]]+.fastlane." Gemfile 2>/dev/null; then echo "Gemfile pins fastlane here, so run every fastlane command below as bundle exec fastlane (a bare fastlane runs $(command -v fastlane || echo nothing), not the pinned copy)."; [ "$(command -v ruby)" = /usr/bin/ruby ] && echo "⚠ System Ruby is first on PATH and bundler fails under it. Prefix each command with PATH=/opt/homebrew/opt/ruby/bin:\$PATH, or run /setup-fastlane to check the setup."; elif command -v fastlane >/dev/null; then echo "✓ $(command -v fastlane) (no Gemfile in this folder)"; else echo "✗ Not found, and no Gemfile in this folder. Install: brew install fastlane"; fi; true`
- Fastfile exists: !`ls fastlane/Fastfile 2>/dev/null && echo "✓ Found" || echo "✗ Not found - run /setup-fastlane first"`
- App-specific password: !`[ -n "$FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" ] && echo "✓ Set" || echo "⚠️ Not set - export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD='xxxx-xxxx-xxxx-xxxx'"`

### Arguments: ${ARGUMENTS:-none}

---

## What This Does

1. **Syncs certificates** via Match (appstore type) — *only once you've run the `match` skill; the base `setup-fastlane` lane skips this*
2. **Increments build number** (unless `--skip-build-increment`)
3. **Builds release archive** with gym
4. **Uploads to TestFlight** via pilot
5. **Optionally distributes to external testers** (via the separate `beta_external` lane)

---

## Commands

### Standard Beta (Internal Testers)
Run from your project directory (where `fastlane/` lives). If the project has a Gemfile, run
every command on this page as `bundle exec fastlane …` so the version in Gemfile.lock runs.
```bash
fastlane beta
```

### Skip Build Number Increment
```bash
fastlane beta skip_build_increment:true
```

### External Testers (with changelog)
```bash
fastlane beta_external changelog:"Bug fixes and performance improvements"
```

---

## Troubleshooting

### "No value found for 'username'"
Set your Apple ID in `fastlane/Appfile`:
```ruby
apple_id("your@email.com")
```

### "Please sign in with an app-specific password"
1. Go to https://account.apple.com → Sign-In & Security → App-Specific Passwords
2. Generate a password named "Fastlane"
3. Export it:
```bash
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD='xxxx-xxxx-xxxx-xxxx'
```

### rsync error during export
If you see `--extended-attributes: unknown option`, Homebrew rsync conflicts with Xcode:
```bash
brew uninstall rsync  # Use system rsync
```

---

## After Upload

- Build will appear in TestFlight within 1-5 minutes
- Internal testers are notified automatically
- External testers require `beta_external` lane or manual distribution in App Store Connect
