#!/usr/bin/env bash
# Tests for skills/setup-fastlane/scripts/env-check.sh. Run: bash tests/env-check.test.sh
# Builds small fake projects in a temp folder; touches nothing else.

set -u

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/skills/setup-fastlane/scripts/env-check.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
failures=0

expect() { # expect <description> <output> <grep -E pattern>
  if printf '%s\n' "$2" | grep -qE -- "$3"; then
    printf 'ok   - %s\n' "$1"
  else
    printf 'FAIL - %s\n       wanted: %s\n' "$1" "$3"
    failures=$((failures + 1))
  fi
}
reject() { # reject <description> <output> <grep -E pattern>
  if printf '%s\n' "$2" | grep -qE -- "$3"; then
    printf 'FAIL - %s\n       did not want: %s\n' "$1" "$3"
    failures=$((failures + 1))
  else
    printf 'ok   - %s\n' "$1"
  fi
}

# A pbxproj where the UI test target's settings come before the app's.
write_pbxproj() { # write_pbxproj <xcodeproj dir>
  mkdir -p "$1/project.xcworkspace"
  cat > "$1/project.pbxproj" <<'EOF'
// !$*UTF8*$!
{
		A1 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				PRODUCT_BUNDLE_IDENTIFIER = com.example.demo.uitests;
				TEST_TARGET_NAME = Demo;
			};
			name = Debug;
		};
		A2 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				PRODUCT_BUNDLE_IDENTIFIER = com.example.demo.tests;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Demo.app/Demo";
			};
			name = Debug;
		};
		A3 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				DEVELOPMENT_TEAM = ABCDE12345;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.demo;
			};
			name = Debug;
		};
}
EOF
}

# --- Fixture 1: existing Bundler setup, app three folders below the repo root
repo="$TMP/repo"
app="$repo/project/product/ios-app"
write_pbxproj "$app/Demo.xcodeproj"
mkdir -p "$app/fastlane" "$repo/ios/Pods/Pods.xcodeproj"
touch "$app/project.yml" "$app/fastlane/Fastfile"
printf 'app_identifier("com.example.demo")\n' > "$app/fastlane/Appfile"
printf 'source "https://rubygems.org"\ngem "fastlane", "~> 2.230"\n' > "$app/Gemfile"
printf 'GEM\n  specs:\n    fastlane (2.232.2)\n\nBUNDLED WITH\n   2.4.22\n' > "$app/Gemfile.lock"

out="$(cd "$repo" && bash "$SCRIPT")"
status=$?
expect "exits 0" "$status" '^0$'
expect "finds the .xcodeproj from the repo root" "$out" 'Xcode project: ✓ .*/project/product/ios-app/Demo.xcodeproj$'
reject "skips Pods.xcodeproj" "$out" 'Pods.xcodeproj'
expect "ignores the workspace inside the .xcodeproj" "$out" 'Workspace: none'
expect "picks the app bundle ID, not a test target's" "$out" 'App bundle ID: ✓ com.example.demo$'
expect "lists test target IDs separately" "$out" 'Test target bundle IDs.*com.example.demo.uitests'
expect "finds the team ID" "$out" 'Team ID: ✓ ABCDE12345'
expect "notices XcodeGen" "$out" 'XcodeGen: ⚠'
expect "reads BUNDLED WITH" "$out" 'BUNDLED WITH: 2.4.22'
expect "reads the locked fastlane" "$out" 'locked fastlane: 2.232.2'
expect "switches to checking mode" "$out" 'MODE: CHECK EXISTING SETUP'
expect "suggests the pinned bundler" "$out" 'bundle _2.4.22_ exec fastlane lanes'

out_arg="$(cd "$TMP" && bash "$SCRIPT" "$app")"
expect "accepts the app folder as an argument" "$out_arg" "Searched from: $app"

# --- Fixture 2: new project, no Gemfile and no Fastfile
fresh="$TMP/fresh"
write_pbxproj "$fresh/Demo.xcodeproj"
out="$(bash "$SCRIPT" "$fresh")"
expect "new project: setup mode" "$out" 'MODE: NEW SETUP'
reject "new project: no XcodeGen warning" "$out" 'XcodeGen'

# --- Fixture 2b: a CocoaPods-only Gemfile is not a fastlane setup
pods="$TMP/pods"
write_pbxproj "$pods/Demo.xcodeproj"
printf 'source "https://rubygems.org"\ngem "cocoapods", "~> 1.16"\n' > "$pods/Gemfile"
out="$(bash "$SCRIPT" "$pods")"
expect "CocoaPods-only Gemfile: setup mode" "$out" 'MODE: NEW SETUP'
expect "CocoaPods-only Gemfile: asks how to install" "$out" 'Ask the user whether to add fastlane'
reject "CocoaPods-only Gemfile: no bundle exec fastlane" "$out" 'exec fastlane lanes'

# --- Fixture 3: nothing to find, and an argument that is not a folder
empty="$TMP/empty"
mkdir -p "$empty"
out="$(cd "$empty" && bash "$SCRIPT" "not a folder")"
status=$?
expect "bad argument: exits 0" "$status" '^0$'
expect "bad argument: says so" "$out" "is not a folder"
expect "no project: the not-found message prints" "$out" 'Xcode project: ✗ none found'

if [ "$failures" -gt 0 ]; then
  printf '\n%s failed\n' "$failures"
  exit 1
fi
printf '\nall passed\n'
