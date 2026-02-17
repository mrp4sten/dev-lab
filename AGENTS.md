# Repository Guidelines

Dev-Lab is a versioned workspace for shared tools and documentation; personal application code lives in git-ignored areas. Use this guide to keep contributions lean and consistent.

## Project Structure & Module Organization
- `docs/` hosts knowledge base material (`docs/cheatsheets/`, `docs/workflows/`); keep additions concise and cross-link when possible.
- `tools/` holds versioned utilities organized in subdirectories:
  - `tools/sonarqube/` contains the Docker Compose stack for local code quality runs
  - `tools/llms-prompt-examples/` stores prompt reference material
  - `tools/scripts/` contains workspace automation scripts (setup, health monitoring, backup)
  - `tools/templates/` provides project scaffolding templates
  - `tools/configs/` holds shared configuration files for linting, formatting, etc.
- `projects/` and `scratch/` are git-ignored for local apps and experiments. Do not commit artifacts from those paths without updating `.gitignore` intentionally.

## Build, Test, and Development Commands
- Repo-wide builds are minimal; most changes are docs or tool configs.
- Workspace automation:
  - `tools/scripts/workspace-setup.sh` - Initialize and configure the workspace
  - `tools/scripts/workspace-health.sh` - Monitor workspace status and health
  - `tools/scripts/backup.sh` - Backup projects and scratch directories
- SonarQube: `docker-compose -f tools/sonarqube/docker-compose.yml up -d` to start, `... logs -f` to tail, `... down` to stop, `... down -v` to wipe volumes (destructive).
- A helper exists at `tools/sonarqube/scripts/sonarqube-manager.sh`; update its `COMPOSE_FILE` path to point to `tools/sonarqube/docker-compose.yml` before using `bash ... start|stop|status`.

## Coding Style & Naming Conventions
- Markdown: ATX headers, short sections, fenced code blocks for commands, bullets over dense paragraphs.
- Shell: Bash with `set -euo pipefail`, four-space indents, lower-kebab file names, and verb-prefixed functions; prefer `readonly` for constants.
- Paths and files should stay lowercase with hyphens; keep secrets and credentials out of version control.

## Testing Guidelines
- Shell scripts: `bash -n path/to/script` and `shellcheck path/to/script` (if available). Run helpers with `--help` first to verify usage.
- SonarQube config: `docker-compose -f tools/sonarqube/docker-compose.yml config` to validate YAML before starting.
- No formal coverage targets yet; describe manual checks in your PR notes.

## Commit & Pull Request Guidelines
- Use conventional commits (`chore:`, `docs:`, `feat:`, etc.) in imperative mood; keep subjects brief.
- PRs should summarize scope, list commands run (tests, `docker-compose` actions), and note data impact (e.g., SonarQube volume resets). Attach screenshots for UI-affecting changes when relevant.
- Keep personal `projects/` and `scratch/` content untracked; ensure generated data or Docker volumes stay out of the repo.
