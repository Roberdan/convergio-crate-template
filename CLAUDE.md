# CLAUDE.md — convergio-CRATE_NAME

Read `AGENTS.md` first. This file adds Claude Code-specific behavior.

Conversation: **Italian**. Code + docs: **English**.
Co-Authored-By: your model name (e.g. `Claude Opus 4.6`)
PRs: auto-merged when CI green. Branch auto-deleted.

## Crate

CRATE_DESCRIPTION

```
crates/convergio-CRATE_NAME/src/
├── lib.rs       — public API, module declarations
├── routes.rs    — HTTP routes
├── ext.rs       — Extension impl (if applicable)
├── schema.rs    — DB migrations (if applicable)
└── types.rs     — crate-specific types (if applicable)
```

## Workflow

1. Read AGENTS.md for build/test/rules
2. Work in worktree: `git worktree add .worktrees/fix-name -b fix/name`
3. Commit conventional, push, create PR with 5 sections
4. Never merge — auto-merge handles it after CI green

## SDK dep

convergio-sdk provides: types, telemetry, security, db.
Never duplicate SDK functionality. Never modify SDK types here.
