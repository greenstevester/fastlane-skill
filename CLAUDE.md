# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code skill plugin that automates Fastlane setup for iOS/macOS projects. It's a self-contained skill package, not a traditional codebase with build/test commands.

## Repository Structure

```
.claude-plugin/
  marketplace.json         # Plugin registry metadata (required location for Claude Code)
skills/
  setup-fastlane.md        # The main skill definition (markdown with embedded commands)
todos.md                   # Roadmap and future skills
```

## Skill File Format

The skill at `skills/setup-fastlane.md` uses Claude Code's skill syntax:
- **Frontmatter** (YAML between `---`): metadata like `description`, `argument-hint`, `allowed-tools`
- **Inline commands** with `!` syntax: e.g., `!`command`` executes shell commands when the skill runs
- **Template placeholders**: `{{BUNDLE_ID}}`, `${ARGUMENTS}` for dynamic values

## Testing the Skill

No build step. To test changes:
1. Copy `skills/setup-fastlane.md` to `~/.claude/commands/setup-fastlane.md`
2. Run `/setup-fastlane` in Claude Code within an Xcode project directory
3. Or install via: `/plugin marketplace add greenstevester/fastlane-skill`

## Key Technical Details

- Uses Homebrew for Fastlane installation (avoids Ruby 4.0 compatibility issues)
- Introspects Xcode `.pbxproj` files to extract bundle ID, team ID, and version
- Creates full `fastlane/metadata/` structure for `deliver` command
- Optionally generates `ci_scripts/` for Xcode Cloud integration

## When Modifying the Skill

- The skill is user-facing documentation and executable instructions combined
- Shell commands in `!` backticks run during skill execution
- Keep the step-by-step structure clear for users to follow
- Test with both new projects (no existing fastlane) and projects with existing configurations
