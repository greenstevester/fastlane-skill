---
name: release
description: Submit iOS app to App Store for review
argument-hint: [--version "1.x.x"] [--auto-release] [--skip-metadata]
allowed-tools: Bash, Read
---

## App Store Production Release

Submit the iOS app to App Store Connect for review and release.

### Pre-flight Checks
- Fastlane installed: !`fastlane --version 2>/dev/null | grep "fastlane " | head -1 || echo "✗ Not installed - run: brew install fastlane"`
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
1. **Syncs certificates** via Match (appstore type)
2. **Bumps version number** (if `version:` provided)
3. **Increments build number**
4. **Builds release archive** with gym
5. **Uploads to App Store Connect**
6. **Submits for review**
7. **Auto-releases after approval** (if `auto_release:true`)

---

## Commands

### Submit Existing TestFlight Build
```bash
cd project/product/swiftui-ios-app  # or your fastlane directory
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

