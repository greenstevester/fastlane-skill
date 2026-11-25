---
name: snapshot
description: Automate App Store screenshot capture across devices and languages
argument-hint: [--devices "iPhone 15 Pro"] [--languages "en-US,ja"]
allowed-tools: Bash, Read, Write, Edit
---

## Automated App Store Screenshots

Set up Fastlane Snapshot to automatically capture App Store screenshots across multiple devices and languages.

### Pre-flight Checks
- Fastlane: !`if grep -qE "^[[:space:]]*gem[[:space:]]+.fastlane." Gemfile 2>/dev/null; then echo "Gemfile pins fastlane here, so run every fastlane command below as bundle exec fastlane (a bare fastlane runs $(command -v fastlane || echo nothing), not the pinned copy)."; [ "$(command -v ruby)" = /usr/bin/ruby ] && echo "⚠ System Ruby is first on PATH and bundler fails under it. Prefix each command with PATH=/opt/homebrew/opt/ruby/bin:\$PATH, or run /setup-fastlane to check the setup."; elif command -v fastlane >/dev/null; then echo "✓ $(command -v fastlane) (no Gemfile in this folder)"; else echo "✗ Not found, and no Gemfile in this folder. Install: brew install fastlane"; fi; true`
- Fastfile exists: !`ls fastlane/Fastfile 2>/dev/null && echo "✓ Found" || echo "✗ Not found - run /setup-fastlane first"`
- Existing Snapfile: !`ls fastlane/Snapfile 2>/dev/null && echo "✓ Already configured" || echo "○ Not configured yet"`
- UI Test target: !`find . -maxdepth 3 -name "*UITests*" -type d 2>/dev/null | head -1 || echo "○ No UI test target found"`
- Simulators available: !`xcrun simctl list devices available | grep -E "iPhone|iPad" | head -3`

### Arguments: ${ARGUMENTS:-setup}

---

## Why Automate Screenshots?

App Store requires screenshots for multiple device sizes. Manual capture means:
- 5+ device sizes × 5+ screenshots × N languages = **hours of work**
- Risk of inconsistency between screenshots
- Repeat everything for each app update

Snapshot automates this: run once, get all screenshots.

---

## Step 1: Initialize Snapshot

If the project has a Gemfile, run every command on this page as `bundle exec fastlane …` so the
version in Gemfile.lock runs.

```bash
fastlane snapshot init
```

This creates:
- `fastlane/Snapfile` - Configuration file
- `fastlane/SnapshotHelper.swift` - Helper for UI tests

---

## Step 2: Configure Snapfile

Edit `fastlane/Snapfile`:

```ruby
# Devices to capture (App Store requirements)
devices([
  "iPhone 15 Pro Max",      # 6.7" display (required)
  "iPhone 15 Pro",          # 6.1" display
  "iPhone SE (3rd generation)", # 4.7" display (if supporting older phones)
  "iPad Pro 13-inch (M4)",  # iPad screenshots (if universal app)
])

# Languages to capture
languages([
  "en-US",
  # "ja",      # Japanese
  # "de-DE",   # German
  # "fr-FR",   # French
  # "es-ES",   # Spanish
])

# UI Test scheme
scheme("YourAppUITests")

# Output directory
output_directory("./fastlane/screenshots")

# Clear old screenshots before capture
clear_previous_screenshots(true)

# Stop on first error (set false to continue despite failures)
stop_after_first_error(true)

# Dark mode variants (iOS 13+)
# dark_mode(true)

# Workspace or project (uncomment one)
# workspace("YourApp.xcworkspace")
# project("YourApp.xcodeproj")
```

---

## Step 3: Add SnapshotHelper to UI Tests

1. **Add SnapshotHelper.swift** to your UI test target:
   - Drag `fastlane/SnapshotHelper.swift` into Xcode
   - Ensure it's added to your **UITests** target (not main app)

2. **Import and configure** in your UI test file:

```swift
import XCTest

class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)  // Initialize snapshot
        app.launch()
    }

    func testTakeScreenshots() throws {
        let app = XCUIApplication()

        // Screenshot 1: Home screen
        snapshot("01_HomeScreen")

        // Navigate to feature and capture
        app.buttons["Feature"].tap()
        snapshot("02_FeatureScreen")

        // Screenshot with content
        app.textFields["Search"].tap()
        app.textFields["Search"].typeText("Example")
        snapshot("03_SearchResults")

        // Settings screen
        app.buttons["Settings"].tap()
        snapshot("04_Settings")

        // Any additional screens...
        snapshot("05_DetailView")
    }
}
```

---

## Step 4: Run Snapshot

```bash
# Capture all screenshots
fastlane snapshot

# Specific device only
fastlane snapshot --devices "iPhone 15 Pro Max"

# Specific language only
fastlane snapshot --languages "en-US"

# Skip launch (use existing simulator state)
fastlane snapshot --skip_open_summary
```

Screenshots are saved to `fastlane/screenshots/{language}/{device}/`.

---

## Step 5: Upload to App Store Connect

After capturing, upload with `deliver`:

```bash
# Upload screenshots only (no binary, no metadata)
fastlane deliver --skip_binary_upload --skip_metadata --overwrite_screenshots
```

`deliver` reads `fastlane/screenshots/<locale>/`, maps each PNG to a display size by its **pixel dimensions**, and orders them by **filename sort** — so prefix names (`01_`, `02_`, …).

### Uploading screenshots you framed yourself

If you frame with your own pipeline (a design tool, a web framer) instead of `frameit`, `deliver` can still upload them — stage them into the `<locale>/` layout and let dimension-mapping place them:

```ruby
lane :upload_framed_screenshots do
  framed  = File.expand_path("../path/to/your/framed", __dir__)
  staging = File.expand_path("./screenshots/en-US", __dir__)   # deliver wants <locale>/
  FileUtils.rm_rf(File.dirname(staging)); FileUtils.mkdir_p(staging)
  FileUtils.cp(Dir.glob("#{framed}/*.png"), staging)
  deliver(skip_binary_upload: true, skip_metadata: true,
          skip_screenshots: false, overwrite_screenshots: true, force: true)
end
```

> **RGB only — no alpha.** App Store rejects screenshots with an alpha channel
> (`ERROR ITMS-90475` / `IMAGE_ALPHA_NOT_ALLOWED`). Web/`toPng` framers usually add
> one — flatten before upload: `magick in.png -alpha remove -alpha off out.png`.

**If your framer is a full editor (not a static page),** don't hand-click its
browser "Export bundle" button — that isn't repeatable and dumps a zip in the
editor's own nested layout. Instead, expose a tiny **dev-only export hook** on
`window` that reuses the editor's existing capture function (it already knows the
exact per-size `toPng` render), then drive it with headless Chrome:

```js
// in the editor (dev only): loop slides × required sizes through the UI's own
// captureSlide(), return base64 PNGs — no zip, no download dialog.
window.__exportFramed = async () => {/* … returns [{name, dataUrl}] */};
```
```js
// driver (puppeteer-core → system Chrome): call the hook, flatten, write flat.
const items = await page.evaluate(() => window.__exportFramed());
for (const { name, dataUrl } of items)
  execFileSync("magick", ["png:-","-alpha","remove","-alpha","off", out(name)],
              { input: Buffer.from(dataUrl.split(",")[1], "base64") });
```

One command regenerates the whole set into your canonical output dir, already
RGB — then point the `upload_framed_screenshots` lane above at that dir. This
beats the editor's bundle button (which still emits RGBA in a layout `deliver`
can't read) and keeps the pipeline scriptable.

### What `deliver` does NOT upload

`deliver` handles **app-level** metadata + screenshots only. It does **not** touch:

- **In-app-purchase / subscription assets** — the per-IAP *Review Information → Screenshot* and the 1024×1024 *Image (Optional)* promo. Upload these **by hand** in App Store Connect (no turnkey fastlane action; the raw ASC API is the only alternative).
- **App icon** — comes from the uploaded **build** (the `AppIcon` asset catalog), never a separate upload.

### Auth

`deliver` needs App Store Connect credentials. For non-interactive/CI runs, configure an **App Store Connect API key** (`.p8`) — see the `match` skill's CI/CD section. With only an Apple ID it falls back to **interactive 2FA**, which can't be scripted.

---

## App Store Screenshot Requirements

### Required Device Sizes

| Display Size | Example Devices |
|-------------|-----------------|
| 6.9" iPhone | iPhone 17 Pro Max, 16 Pro Max, 15 Pro Max, 14 Pro Max, 16/15 Plus |
| 6.5" iPhone | iPhone 14 Plus, 13/12/11 Pro Max, XS Max, XR |
| 13" iPad | iPad Pro (M5/M4), iPad Air (M4/M3/M2) |
| 12.9" iPad | iPad Pro (2nd gen) |

> **Minimum**: 6.9" iPhone screenshots are the primary requirement. 6.5" is only required if 6.9" aren't provided. Smaller iPhone sizes (6.3", 6.1", 5.5", 4.7") auto-scale from the larger ones — only supply them if you want pixel-perfect framing on those displays. iPad screenshots are required if the app runs on iPad.

For exact pixel dimensions, see Apple's [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications) — they update with each new device generation, so always check the current source.

### Screenshot Count
- **Minimum**: 1 per device size
- **Maximum**: 10 per device size
- **Recommended**: 5-6 highlighting key features

---

## Optional: Frame Screenshots with Device Bezels

Add device frames around screenshots using `frameit`:

```bash
# Install frameit
brew install imagemagick

# Frame screenshots
fastlane frameit

# Silver device frames
fastlane frameit silver
```

Create `fastlane/screenshots/Framefile.json` for custom titles:

```json
{
  "default": {
    "title": {
      "font": "./fonts/MyFont.ttf",
      "color": "#000000"
    },
    "background": "#FFFFFF",
    "padding": 50,
    "show_complete_frame": true
  }
}
```

---

## Troubleshooting

### "SnapshotHelper.swift not found"
Re-run `fastlane snapshot init` and add the helper to your UI test target.

### "Unable to boot simulator"
Reset the simulator:
```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

### Screenshots are black/blank
- Ensure `setupSnapshot(app)` is called **before** `app.launch()`
- Add small delays if content loads asynchronously:
```swift
sleep(1)  // Wait for content
snapshot("01_HomeScreen")
```

### "No matching device found"
Check available simulators:
```bash
xcrun simctl list devices available
```
Update Snapfile device names to match exactly.

### UI test fails to find element
Use accessibility identifiers:
```swift
// In your app code
button.accessibilityIdentifier = "settingsButton"

// In UI test
app.buttons["settingsButton"].tap()
```

### Paywall/price screenshots show the wrong currency

Under any automated run (`xcodebuild`, `fastlane snapshot`, `simctl`), StoreKit renders `Product.displayPrice` from the **US storefront** — regardless of the device region or the `.storekit` `_storefront`/`_locale`. Only the Xcode IDE **Run** button honours a configured storefront, and that can't be scripted. To screenshot a price in another currency, render it from your own region/pricing source behind a `#if DEBUG`, launch-arg-gated hook instead of relying on live StoreKit.

---

## Integrate with Fastfile

Add a dedicated lane for screenshots:

```ruby
lane :screenshots do
  snapshot(
    scheme: "YourAppUITests",
    devices: ["iPhone 15 Pro Max", "iPad Pro 13-inch (M4)"],
    languages: ["en-US"]
  )
  # Optional: frame screenshots
  # frameit(white: true)
end

lane :upload_screenshots do
  deliver(
    skip_binary_upload: true,
    skip_metadata: true,
    overwrite_screenshots: true
  )
end
```

---

## Best Practices

1. **Use sample data**: Pre-populate app with attractive demo content
2. **Consistent state**: Reset app state before each test run
3. **Accessibility IDs**: More reliable than text matching
4. **Handle async**: Add waits for network content to load
5. **Dark mode**: Capture both light and dark variants
6. **Localization**: Test with actual translations, not placeholders
7. **Landscape**: Include landscape screenshots for iPad if relevant

---

## Files Created

```
fastlane/
├── Snapfile                    # Snapshot configuration
├── SnapshotHelper.swift        # Helper for UI tests (copy to test target)
└── screenshots/
    ├── en-US/
    │   ├── iPhone 15 Pro Max/
    │   │   ├── 01_HomeScreen.png
    │   │   ├── 02_FeatureScreen.png
    │   │   └── ...
    │   └── iPad Pro 13-inch (M4)/
    │       └── ...
    └── ja/
        └── ...
```

---

## Complete Workflow

```bash
# 1. Set up snapshot
fastlane snapshot init

# 2. Write UI tests with snapshot() calls

# 3. Capture screenshots
fastlane snapshot

# 4. Review screenshots in fastlane/screenshots/

# 5. Optional: add device frames
fastlane frameit

# 6. Upload to App Store Connect
fastlane deliver --skip_binary_upload --skip_metadata
```
