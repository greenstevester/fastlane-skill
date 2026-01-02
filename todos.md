# Fastlane Skill - TODOs

## Marketplace Submission

- [x] Submit to [SkillsMP](https://skillsmp.com/) — [PR #36](https://github.com/travisvn/awesome-claude-skills/pull/36)

## Additional Skills to Create

- [x] **match** - Code signing certificate management skill
- [x] **snapshot** - Automated App Store screenshot skill
- [ ] **gym** - Build and archive iOS apps skill
- [x] ~~**pilot**~~ - Covered by `beta.md`
- [x] ~~**deliver**~~ - Covered by `release.md`

## Improvements to Existing Skills

- [x] Add example prompts and clarify skills are natural language, not slash commands (README)
- [x] Simplify setup-fastlane/SKILL.md - one-time setup messaging with ASCII art
- [x] Add ASCII art walkthrough (included in setup-fastlane simplification)
- [x] Add support for workspace (`.xcworkspace`) detection
- [x] Add App Store Connect API key setup guidance (in `match.md` CI/CD section)
- [ ] Add CI/CD integration examples (GitHub Actions, Bitrise)
- [x] Add `Matchfile` template generation (in `match.md`)

## Android Support

Current skills are tested for iOS/macOS only. Future Android work:

- [ ] **setup-fastlane-android** - Gradle project introspection, `supply` setup
- [ ] **beta-android** - Google Play internal/alpha/beta track uploads
- [ ] **release-android** - Google Play production releases
- [ ] **screengrab** - Automated Android screenshot capture
- [ ] Update existing skills to detect platform (iOS vs Android)

## Notes

- First Fastlane skills on SkillsMP
- Five skills available: `setup-fastlane`, `beta`, `release`, `match`, `snapshot`
- Version bumped to 1.1.0 with workspace detection improvements
