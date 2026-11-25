#!/usr/bin/env bash
# Environment check for the setup-fastlane skill.
#
# Usage: env-check.sh [folder]
#   folder: where to start looking (default: current folder). It may be a repo
#   root several levels above the .xcodeproj.
#
# Reads only. Changes nothing, installs nothing, runs no bundler or fastlane lane.
# Always exits 0: Claude Code drops the whole skill when an inline command fails.

set -u

MAX_DEPTH=6
# Folders that never hold the app's own project or fastlane setup.
PRUNE=(-name .git -o -name node_modules -o -name Pods -o -name Carthage -o -name .build
  -o -name DerivedData -o -name build -o -name vendor -o -name .bundle -o -name SourcePackages)

say() { printf '%s\n' "$*"; }

# --- where to search -------------------------------------------------------
arg="${1:-}"
arg="${arg/#\~/$HOME}"
if [ -n "$arg" ] && [ -d "$arg" ]; then
  root="$arg"
elif [ -n "$arg" ]; then
  say "⚠ Argument '$1' is not a folder. Searching from the current folder instead."
  root="."
else
  root="."
fi
root="$(cd "$root" && pwd)"

find_pruned() { # find_pruned <name-pattern> [extra prune name]
  local extra=()
  [ -n "${2:-}" ] && extra=(-o -name "$2")
  # ${extra[@]+...} because macOS bash 3.2 calls an empty array unbound under set -u.
  find "$root" -maxdepth "$MAX_DEPTH" \( "${PRUNE[@]}" ${extra[@]+"${extra[@]}"} \) -prune \
    -o -name "$1" -print 2>/dev/null
}

# --- tools -----------------------------------------------------------------
say "## Tools"
if xcode_path="$(xcode-select -p 2>/dev/null)"; then
  say "- Xcode command line tools: ✓ $xcode_path"
else
  say "- Xcode command line tools: ✗ not found. Run: xcode-select --install"
fi

if brew_version="$(brew --version 2>/dev/null | head -1)" && [ -n "$brew_version" ]; then
  say "- Homebrew: ✓ $brew_version"
else
  say "- Homebrew: ✗ not found (https://brew.sh)"
fi

ruby_on_path="$(command -v ruby 2>/dev/null || true)"
ruby_on_path_version="$(ruby --version 2>/dev/null | awk '{print $2}')"
homebrew_ruby_bin=""
for candidate in /opt/homebrew/opt/ruby/bin /usr/local/opt/ruby/bin; do
  if [ -x "$candidate/ruby" ]; then homebrew_ruby_bin="$candidate"; break; fi
done

if [ -z "$ruby_on_path" ]; then
  say "- Ruby on PATH: ✗ none"
elif [ "$ruby_on_path" = "/usr/bin/ruby" ]; then
  say "- Ruby on PATH: ⚠ $ruby_on_path ($ruby_on_path_version) is macOS System Ruby."
  say "  Bundler under System Ruby cannot load gems built for Homebrew Ruby"
  say "  (Bundler::GemNotFound, \"extensions are not built\", \"Could not find 'bundler'\")."
  if [ -n "$homebrew_ruby_bin" ]; then
    say "  Homebrew Ruby is installed: $homebrew_ruby_bin ($("$homebrew_ruby_bin/ruby" --version 2>/dev/null | awk '{print $2}'))."
    say "  Put it first in PATH for each Ruby command: PATH=\"$homebrew_ruby_bin:\$PATH\" <command>"
  fi
else
  say "- Ruby on PATH: ✓ $ruby_on_path ($ruby_on_path_version)"
fi

# The Ruby that bundler commands should run under.
if [ "$ruby_on_path" = "/usr/bin/ruby" ] && [ -n "$homebrew_ruby_bin" ]; then
  use_ruby_bin="$homebrew_ruby_bin"
  path_prefix="PATH=\"$homebrew_ruby_bin:\$PATH\" "
else
  use_ruby_bin="$(dirname "${ruby_on_path:-/usr/bin/ruby}")"
  path_prefix=""
fi

fastlane_on_path="$(command -v fastlane 2>/dev/null || true)"
if [ -n "$fastlane_on_path" ]; then
  fastlane_on_path_version="$(FASTLANE_SKIP_UPDATE_CHECK=1 fastlane --version 2>/dev/null \
    | grep -oE 'fastlane [0-9][0-9.]*' | head -1)"
  say "- Bare \`fastlane\` command runs: $fastlane_on_path (${fastlane_on_path_version:-version unknown})"
else
  say "- Bare \`fastlane\` command: not on PATH"
fi

# --- project ---------------------------------------------------------------
say ""
say "## Project"
say "- Searched from: $root (up to $MAX_DEPTH folders deep)"

projects="$(find_pruned '*.xcodeproj' | sort)"
if [ -z "$projects" ]; then
  say "- Xcode project: ✗ none found. Pass the app folder as the argument: /setup-fastlane <path>"
  app_dir="$root"
else
  project="$(printf '%s\n' "$projects" | head -1)"
  app_dir="$(dirname "$project")"
  say "- Xcode project: ✓ $project"
  project_count="$(printf '%s\n' "$projects" | wc -l | tr -d ' ')"
  if [ "$project_count" -gt 1 ]; then
    say "  ⚠ $project_count projects found. Using the first. Others:"
    printf '%s\n' "$projects" | tail -n +2 | sed 's/^/    /'
  fi
fi

# Skip the project.xcworkspace that lives inside every .xcodeproj.
workspaces="$(find_pruned '*.xcworkspace' '*.xcodeproj' | sort)"
if [ -n "$workspaces" ]; then
  say "- Workspace: ✓ $(printf '%s\n' "$workspaces" | head -1)"
else
  say "- Workspace: none (fine; fastlane uses the .xcodeproj)"
fi

if [ -f "$app_dir/project.yml" ]; then
  say "- XcodeGen: ⚠ $app_dir/project.yml found. The .xcodeproj is generated from it."
  say "  Change project.yml and regenerate (xcodegen generate). Never edit project.pbxproj by hand."
fi

pbxproj="${project:-}/project.pbxproj"
if [ -n "${project:-}" ] && [ -f "$pbxproj" ]; then
  # One line per build configuration: "<bundle id> <app|test>". A configuration that
  # sets TEST_HOST, TEST_TARGET_NAME or BUNDLE_LOADER belongs to a test target.
  ids="$(awk '
    /buildSettings = \{/ { inb = 1; id = ""; test = 0; next }
    inb && /PRODUCT_BUNDLE_IDENTIFIER = / { v = $0; sub(/.*= */, "", v); gsub(/[";]/, "", v); id = v }
    inb && /(TEST_HOST|TEST_TARGET_NAME|BUNDLE_LOADER) = / { test = 1 }
    inb && /^[[:space:]]*\};/ { if (id != "") print id, (test ? "test" : "app"); inb = 0 }
  ' "$pbxproj" | sort -u)"
  app_ids="$(printf '%s\n' "$ids" | awk '$2 == "app" { print $1 }' | sort -u)"
  test_ids="$(printf '%s\n' "$ids" | awk '$2 == "test" { print $1 }' | sort -u)"
  app_id_count="$(printf '%s' "$app_ids" | grep -c . || true)"

  if [ "$app_id_count" -eq 1 ]; then
    say "- App bundle ID: ✓ $app_ids"
  elif [ "$app_id_count" -gt 1 ]; then
    say "- App bundle ID: ⚠ several non-test targets. Ask the user which one is the app:"
    printf '%s\n' "$app_ids" | sed 's/^/    /'
  else
    say "- App bundle ID: ✗ not found in $pbxproj"
  fi
  [ -n "$test_ids" ] && say "- Test target bundle IDs (not the app): $(printf '%s' "$test_ids" | tr '\n' ' ')"

  team_ids="$(grep -E 'DEVELOPMENT_TEAM = ' "$pbxproj" | sed 's/.*= //' | tr -d '";' | grep -v '^$' | sort -u)"
  team_count="$(printf '%s' "$team_ids" | grep -c . || true)"
  if [ "$team_count" -eq 1 ]; then
    say "- Team ID: ✓ $team_ids"
  elif [ "$team_count" -gt 1 ]; then
    say "- Team ID: ⚠ several found. Ask the user: $(printf '%s' "$team_ids" | tr '\n' ' ')"
  else
    say "- Team ID: ✗ not set in the project"
  fi
fi

# --- existing fastlane setup -----------------------------------------------
say ""
say "## Existing Fastlane setup"

fastfile="$(find_pruned 'Fastfile' | grep '/fastlane/Fastfile$' | head -1)"
if [ -n "$fastfile" ]; then
  fastlane_dir="$(dirname "$(dirname "$fastfile")")"
  say "- fastlane/Fastfile: ✓ $fastfile"
else
  fastlane_dir="$app_dir"
  say "- fastlane/Fastfile: none"
fi

appfile="$fastlane_dir/fastlane/Appfile"
if [ -f "$appfile" ]; then
  appfile_id="$(grep -E '^[[:space:]]*app_identifier' "$appfile" | head -1 | sed -E 's/.*\(["'\'']([^"'\'']+).*/\1/')"
  say "- fastlane/Appfile: ✓ app_identifier ${appfile_id:-(not set)}"
fi

# Bundler looks for the Gemfile in the folder it runs in, then in parent folders.
gemfile=""
dir="$fastlane_dir"
while :; do
  if [ -f "$dir/Gemfile" ]; then gemfile="$dir/Gemfile"; break; fi
  [ "$dir" = "$root" ] || [ "$dir" = "/" ] && break
  dir="$(dirname "$dir")"
done

pin=""
if [ -z "$gemfile" ]; then
  say "- Gemfile: none"
else
  say "- Gemfile: ✓ $gemfile"
  pin="$(grep -E '^[[:space:]]*gem[[:space:]]+["'\'']fastlane["'\'']' "$gemfile" | head -1 | sed 's/^[[:space:]]*//')"
  say "  fastlane line: ${pin:-(no fastlane gem listed, so bundler does not manage fastlane here)}"
fi

lockfile="${gemfile:+$gemfile.lock}"
bundler_version=""
if [ -n "$lockfile" ] && [ -f "$lockfile" ]; then
  bundler_version="$(awk '/^BUNDLED WITH/ { getline; gsub(/[[:space:]]/, ""); print; exit }' "$lockfile")"
  locked_fastlane="$(grep -E '^    fastlane \(' "$lockfile" | head -1 | grep -oE '[0-9][0-9.]*')"
  say "- Gemfile.lock: ✓ $lockfile"
  say "  BUNDLED WITH: ${bundler_version:-(missing)}"
  say "  locked fastlane: ${locked_fastlane:-(not in lock)}"
  if [ -n "$bundler_version" ]; then
    if "$use_ruby_bin/gem" list -i bundler -v "$bundler_version" >/dev/null 2>&1; then
      say "  bundler $bundler_version for $use_ruby_bin/ruby: ✓ installed"
    else
      say "  bundler $bundler_version for $use_ruby_bin/ruby: ✗ not installed."
      say "  Ask before installing: ${path_prefix}gem install bundler -v $bundler_version"
    fi
  fi
elif [ -n "$gemfile" ]; then
  say "- Gemfile.lock: none next to the Gemfile"
fi

# --- verdict ---------------------------------------------------------------
say ""
say "## Mode"
# A Gemfile counts only when it lists fastlane; many hold just CocoaPods.
if [ -n "$fastfile" ] || [ -n "$pin" ]; then
  say "MODE: CHECK EXISTING SETUP. Change nothing. Do not write an Appfile or a Fastfile."
  if [ -n "$pin" ]; then
    b="bundle"
    [ -n "$bundler_version" ] && b="bundle _${bundler_version}_"
    say "Run these from $fastlane_dir:"
    say "  ${path_prefix}BUNDLE_FROZEN=true $b check --dry-run"
    say "  ${path_prefix}BUNDLE_FROZEN=true FASTLANE_SKIP_UPDATE_CHECK=1 $b exec fastlane lanes"
    if [ -n "$fastlane_on_path" ]; then
      say "Do not use the bare \`fastlane\` command here: it runs $fastlane_on_path, not the Gemfile's copy."
    fi
  else
    say "No Gemfile lists fastlane, so the bare fastlane command is the one in use. Run from $fastlane_dir:"
    say "  FASTLANE_SKIP_UPDATE_CHECK=1 fastlane lanes"
  fi
else
  say "MODE: NEW SETUP. No Fastfile, and no Gemfile that lists fastlane."
  [ -n "$gemfile" ] && say "The Gemfile exists (CocoaPods or other tools). Ask the user whether to add fastlane to it or install with Homebrew."
fi

exit 0
