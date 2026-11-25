---
name: setup-fastlane
description: Set up Fastlane for an iOS or macOS app, or check that an existing Fastlane setup still works. Use this whenever a project has a fastlane/Fastfile, Gemfile or Gemfile.lock and the task touches them, even if nobody says "setup". That covers testing a dependency-bot pull request (Dependabot, Renovate) that bumps a gem in Gemfile.lock, any Gemfile or Gemfile.lock change, reinstalling bundler, bundler errors (Bundler::GemNotFound, "extensions are not built", "Could not find 'bundler'"), `bundle exec fastlane` failing, and fastlane that won't load or won't list its lanes. Also use it for a first-time setup that installs fastlane, writes the Appfile and Fastfile, and finds the app's bundle ID and team ID.
argument-hint: [project-path]
allowed-tools: Bash, Read, Write, Edit, Glob
---

## Fastlane Setup and Health Check

This skill does one of two jobs, and the environment check below decides which:

- **Check an existing setup.** The project already has a Fastfile or a Gemfile. Confirm it
  still loads, report what passed, and change nothing.
- **New setup.** No Fastfile or Gemfile yet. Install fastlane and write the config files.

### Environment Check
!`bash "${CLAUDE_SKILL_DIR}/scripts/env-check.sh" 2>&1 || true`

Argument given to the skill (may be empty): $ARGUMENTS

The check searches from the current folder, up to six folders deep, so a session that starts at
a repo root still finds an app folder like `project/product/ios-app`. The argument is not passed
to the line above, because a backtick in it would break the skill load. If the argument names a
folder, or the check found nothing or the wrong project, rerun it with the app folder:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/env-check.sh" path/to/app-folder
```

Read the `MODE:` line, then follow the matching section. Use the bundle ID the check labels as
the app's. Test targets have their own IDs (`.tests`, `.uitests`), and a plain grep of
`project.pbxproj` often returns one of those first. If the check lists several candidates, ask
the user which one is the app.

---

## Check an Existing Setup

Use this when the check prints `MODE: CHECK EXISTING SETUP`. The project's Fastlane setup is
someone's working configuration, so the job is to confirm it loads. Don't write an Appfile or
a Fastfile, don't run `fastlane init`, and don't edit the Gemfile.

### 1. Use the project's own bundler and fastlane

When a Gemfile lists fastlane, the Gemfile.lock decides which fastlane version runs, and
bundler is the only thing that honours it. A bare `fastlane` command runs whichever copy is
first on PATH, usually Homebrew's `/opt/homebrew/bin/fastlane`, and skips the pinned one. A
check run that way proves nothing about the project's setup.

Run bundler at the version in the `BUNDLED WITH` line at the bottom of Gemfile.lock. The check
prints it. For `BUNDLED WITH 2.4.22`, the commands start with `bundle _2.4.22_`.

### 2. Run under the right Ruby

The Bash tool in Claude Code often starts with macOS System Ruby (`/usr/bin/ruby`, Ruby 2.6)
first on PATH, even when the user's terminal uses Homebrew Ruby. Gems installed for Homebrew
Ruby don't load under System Ruby. Bundler then fails with `Bundler::GemNotFound`,
`extensions are not built`, or `Could not find 'bundler' (2.4.22)`.

If the check flagged System Ruby, tell the user, and put Homebrew Ruby first in PATH for each
command only:

```bash
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle _2.4.22_ check --dry-run
```

(Intel Macs use `/usr/local/opt/ruby/bin`.) Never edit `~/.zshrc`, `~/.zprofile`,
`~/.bash_profile` or any other shell config file; the user decides how their shell starts. Don't
install gems into System Ruby either, and never with `sudo`.

### 3. Run the checks

From the folder that holds `fastlane/` (the check prints the exact commands):

```bash
PATH="/opt/homebrew/opt/ruby/bin:$PATH" BUNDLE_FROZEN=true bundle _2.4.22_ check --dry-run
PATH="/opt/homebrew/opt/ruby/bin:$PATH" BUNDLE_FROZEN=true FASTLANE_SKIP_UPDATE_CHECK=1 \
  bundle _2.4.22_ exec fastlane lanes
```

- `BUNDLE_FROZEN=true` makes bundler refuse to rewrite Gemfile.lock.
- `--dry-run` stops `bundle check` from writing the lockfile when it passes.
- `FASTLANE_SKIP_UPDATE_CHECK=1` hides fastlane's "new version available" banner.
- `fastlane lanes` loads fastlane, its plugins and the Fastfile, so a broken or missing gem in
  that set shows up here. It runs no lane. A gem that an action loads only when it runs (for
  example `mini_magick` for frameit) shows up only when that lane runs, so say so in the report.

If the project has no Gemfile, run `FASTLANE_SKIP_UPDATE_CHECK=1 fastlane lanes` instead.

**If `bundle check` says gems are missing**, as it will after a pull request bumps a gem, ask
the user before installing them. `BUNDLE_FROZEN=true bundle _2.4.22_ install` installs the
gems on this Mac and leaves Gemfile.lock alone.

**If the pinned bundler isn't installed** for Homebrew Ruby, ask before running
`PATH="/opt/homebrew/opt/ruby/bin:$PATH" gem install bundler -v 2.4.22`.

### 4. Report and stop

Report each check as passed or failed, with the versions used. The values below are an
example from one project; report the ones you found:

| Check | Result |
|-------|--------|
| Ruby | `/opt/homebrew/opt/ruby/bin/ruby` 4.0.x (System Ruby was first on PATH) |
| Bundler | 2.4.22, from `BUNDLED WITH` |
| `bundle check` | passed |
| fastlane (from Gemfile.lock) | 2.232.2 |
| `fastlane lanes` | passed, 26 lanes |

Then list anything that needs the user's decision, such as missing gems or a bundler version
to install. Leave the project's files as they were.

---

## New Setup

Use this when the check prints `MODE: NEW SETUP`.

### Step 1: Install Fastlane

With no Gemfile in the project, install fastlane with Homebrew:

```bash
brew install fastlane
```

Homebrew's fastlane carries its own Ruby and gems, so there is no Ruby version or Gemfile to
manage. Teams that want every machine and CI run on the same fastlane version can add a
Gemfile later. The existing-setup checks above then apply.

> **Bundler 4 history:** fastlane 2.230.0 and earlier required bundler below 3.0, so they
> failed to load once Bundler 4.0 arrived in December 2025
> ([fastlane issue #29817](https://github.com/fastlane/fastlane/issues/29817)).
> fastlane 2.231.0, released 16 January 2026, accepts Bundler 4
> ([pull request #29813](https://github.com/fastlane/fastlane/pull/29813)). A project
> locked to fastlane 2.230.0 or older still needs bundler 2.x.

### Step 2: Create Configuration Files

Fill the placeholders from the environment check: the app's bundle ID (not a test target's)
and the team ID. Ask the user for their Apple ID email.

If the check found a `project.yml`, the project is generated by XcodeGen. Any project change
(bundle ID, team, signing) goes in `project.yml` followed by `xcodegen generate`. Don't tell
the user to edit `project.pbxproj`, because the next generate overwrites it. The same goes for
`increment_build_number` in the lanes below: it writes the build number into `project.pbxproj`,
and the next generate puts back whatever `project.yml` says. Tell the user, and let them choose
between keeping the build number in `project.yml` or passing one in with
`increment_build_number(build_number: …)` from a source that survives a regenerate, such as
`latest_testflight_build_number + 1`.

#### `fastlane/Appfile`
```ruby
app_identifier("{{BUNDLE_ID}}")  # Your bundle ID
apple_id("{{APPLE_ID}}")         # Your Apple ID email
team_id("{{TEAM_ID}}")           # Your team ID
```

#### `fastlane/Fastfile`
```ruby
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan(scheme: "{{SCHEME}}")
  end

  desc "Upload to TestFlight (internal testers)"
  lane :beta do |options|
    increment_build_number unless options[:skip_build_increment]
    gym(scheme: "{{SCHEME}}", export_method: "app-store")
    pilot(skip_waiting_for_build_processing: true)
  end

  desc "Upload to TestFlight and distribute to external testers"
  lane :beta_external do |options|
    increment_build_number
    gym(scheme: "{{SCHEME}}", export_method: "app-store")
    pilot(
      distribute_external: true,
      groups: ["External Testers"],
      changelog: options[:changelog] || "Bug fixes and improvements",
      skip_waiting_for_build_processing: false
    )
  end

  desc "Submit the latest TestFlight build for App Store review"
  lane :release do
    deliver(
      build_number: latest_testflight_build_number.to_s,
      submit_for_review: true,
      automatic_release: false,
      force: true,
      skip_binary_upload: true,
      skip_metadata: false,
      skip_screenshots: false
    )
  end

  desc "Build, upload, and submit a fresh build to the App Store"
  lane :release_full do |options|
    increment_version_number(version_number: options[:version]) if options[:version]
    increment_build_number
    gym(scheme: "{{SCHEME}}", export_method: "app-store")
    deliver(
      submit_for_review: true,
      automatic_release: options[:auto_release] == true,
      force: true
    )
  end
end
```

Replace `{{SCHEME}}` with your app's scheme name (usually the app name).

### Step 3: Set Up Metadata (Optional)

Download your existing App Store listing:
```bash
fastlane deliver download_metadata
fastlane deliver download_screenshots
```

This creates `fastlane/metadata/` with editable text files for your app description, keywords, etc.

### You're Done

```bash
# Verify setup
fastlane lanes

# Run your first lane
fastlane ios test
```

If the project has a Gemfile, put `bundle exec` in front of each `fastlane` command.

| Command | What it does |
|---------|--------------|
| `fastlane ios test` | Run tests |
| `fastlane ios beta` | Build + TestFlight |
| `fastlane ios release` | Build + App Store |
| `fastlane deliver download_metadata` | Fetch App Store listing |

---

## When rubygems.org Can't Be Reached

**This is a workaround, not a fix.** The cause was never found.

Symptom: `gem install` and `bundle install` hang with no output, while
`curl -I https://rubygems.org` answers straight away. Ask the user before installing anything
this way, and run each command with Homebrew Ruby first in PATH, as in the checks above.

1. Install bundler from the local gem cache. Ruby keeps the `.gem` files it has downloaded:
   ```bash
   ls "$(gem env gemdir)/cache/" | grep bundler
   gem install --local "$(gem env gemdir)/cache/bundler-2.4.22.gem"
   ```
2. Download each missing gem with curl, then install it from the file:
   ```bash
   curl -fL -o /tmp/<name>-<version>.gem https://rubygems.org/downloads/<name>-<version>.gem
   gem install --local --ignore-dependencies /tmp/<name>-<version>.gem
   ```
   Use the full name from Gemfile.lock. Gems built for one platform carry it in the name, for
   example `nokogiri-1.18.9-arm64-darwin`.
   `--ignore-dependencies` stops gem from trying the network for dependencies. It also stops it
   from checking them, so run `bundle _<version>_ check --dry-run` afterwards to find any that
   are still missing.

---

## Next Steps

- **Code signing issues?** Ask: "Set up Match for code signing"
- **Need screenshots?** Ask: "Automate my App Store screenshots"
- **CI/CD setup?** See [Xcode Cloud guide](../../docs/xcode-cloud.md)
