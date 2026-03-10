# Git Conventions

## 1. Core Summary

This repository appears to use a trunk-oriented branch model centered on `main`, with local topic branches for active work. The inspected history is mostly linear and readable, with short subject lines that often start with a bracketed subsystem scope such as `[runtime]`, `[storage/qmdb]`, or `[docs]`. Commit messages also mix in conventional prefixes like `chore:` and release markers like `[release]`, and merged GitHub PRs commonly include issue or PR numbers in parentheses. The repo guidance also requires intent-first commit bodies with decision trailers when a commit needs more context.

## 2. Source of Truth

- **Primary Code:** `git log --oneline -n 80` - Recent commit subjects show the active message style and scope formatting.
- **Primary Code:** `git log --pretty=format:'%s' -n 120` - Confirms the subject-line patterns across a longer slice of history.
- **Configuration:** `git branch -a` - Shows the visible branch topology (`main`, local `docs`, and `origin/main`).
- **Related Architecture:** `README.md:85-89` - Contribution workflow and tracker references.
- **Related Architecture:** `AGENTS.md` - Repository commit protocol and lore-trailer requirements.
