---
name: release
description: Submit iOS app to App Store for review
argument-hint: [--version "1.x.x"] [--auto-release] [--skip-metadata]
allowed-tools: Bash, Read
---

## App Store Production Release

Submit the iOS app to App Store Connect for review and release.

### Pre-flight Checks
- Fastlane: !`if grep -qE "^[[:space:]]*gem[[:space:]]+.fastlane." Gemfile 2>/dev/null; then echo "Gemfile pins fastlane here, so run every fastlane command below as bundle exec fastlane (a bare fastlane runs $(command -v fastlane || echo nothing), not the pinned copy)."; [ "$(command -v ruby)" = /usr/bin/ruby ] && echo "⚠ System Ruby is first on PATH and bundler fails under it. Prefix each command with PATH=/opt/homebrew/opt/ruby/bin:\$PATH, or run /setup-fastlane to check the setup."; elif command -v fastlane >/dev/null; then echo "✓ $(command -v fastlane) (no Gemfile in this folder)"; else echo "✗ Not found, and no Gemfile in this folder. Install: brew install fastlane"; fi; true`
- Fastfile exists: !`ls fastlane/Fastfile 2>/dev/null && echo "✓ Found" || echo "✗ Not found - run /setup-fastlane first"`
- App-specific password: !`[ -n "$FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" ] && echo "✓ Set" || echo "⚠️ Not set - export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD='xxxx-xxxx-xxxx-xxxx'"`

### Arguments: ${ARGUMENTS:-none}

---

## What This Does

### `fastlane release` (Submit Existing Build)
1. **Selects latest TestFlight build** already uploaded
2. **Submits for App Store review**
3. Ideal when you've already tested a beta build

### `fastlane release_full` (Full Pipeline)
1. **Syncs certificates** via Match (appstore type) — *only once you've run the `match` skill; the base `setup-fastlane` lane skips this*
2. **Bumps version number** (if `version:` provided)
3. **Increments build number**
4. **Builds release archive** with gym
5. **Uploads to App Store Connect**
6. **Submits for review**
7. **Auto-releases after approval** (if `auto_release:true`)

> **Scope:** `release` / `release_full` upload the **binary + app-level metadata/screenshots**.
> They do **not** upload **in-app-purchase / subscription assets** (per-IAP *Review
> Information → Screenshot*, 1024² *Image (Optional)* promos) — those are managed by hand
> in App Store Connect. See the `snapshot` skill for screenshot upload details
> (`deliver` layout, RGB/no-alpha, what it does and doesn't cover).

---

## Commands

### Submit Existing TestFlight Build
Run from your project directory (where `fastlane/` lives). If the project has a Gemfile, run
every command on this page as `bundle exec fastlane …` so the version in Gemfile.lock runs.
```bash
fastlane release
```

### Full Release with Version Bump
```bash
fastlane release_full version:"1.1.0"
```

### Full Release with Auto-Release
```bash
fastlane release_full version:"1.2.0" auto_release:true
```
This will automatically release to the App Store once Apple approves the build.

---

## Workflow Recommendation

1. **Test first**: Run `fastlane beta` to upload to TestFlight
2. **Verify in TestFlight**: Ensure the build works correctly
3. **Submit for review**: Run `fastlane release` to submit the tested build
4. **Or full pipeline**: Use `fastlane release_full` for a fresh build + submit

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

### "The provided entity includes an attribute with a value that has already been used"
The version number already exists. Increment the version:
```bash
fastlane release_full version:"1.0.1"
```

### Build rejected or needs changes
1. Address Apple's feedback
2. Increment build number and re-upload:
```bash
fastlane beta
```
3. Submit again:
```bash
fastlane release
```

---

## After Submission

- **Review time**: Typically 24-48 hours (can be longer)
- **Check status**: App Store Connect → My Apps → Your App → App Store
- **If rejected**: Review feedback, fix issues, increment build, resubmit
- **If approved with auto_release**: App goes live immediately
- **If approved without auto_release**: Manually release in App Store Connect

