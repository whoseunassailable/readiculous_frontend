# Project Rules

- Follow the existing architecture when creating new files or features. Each feature under `lib/features/<name>/` is split into `data/`, `domain/`, and `presentation/` — match that layering (data sources → repositories → domain contracts → presentation/state management) rather than introducing a different pattern. State management is Riverpod throughout (no BLoC) — use the existing provider/notifier conventions already present in the codebase.
- Never make a git commit or push without asking first, every time. Always show what would be committed and get explicit confirmation before running `git commit` or `git push`.
- When asked to make a commit, write a clear, sensible commit message describing the change. Do not add any AI/Claude attribution, byline, or co-author line (e.g. no "Co-Authored-By: Claude", no "Generated with Claude Code", no mention of Claude anywhere in the message).
- Once a feature is fully built, write validation and test cases for it before considering it done — don't leave a feature untested.
- When a new implementation replaces an old one, remove the old/redundant code once the replacement is confirmed working — don't leave both paths coexisting in the codebase.
