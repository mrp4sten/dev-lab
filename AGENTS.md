# Repository Guidelines

Dev-Lab is a versioned workspace for shared tools and documentation; personal application code lives in git-ignored areas. Use this guide to keep contributions lean and consistent.

## Project Structure & Module Organization

```
dev-lab/
├── docs/                         # Knowledge base (cheatsheets, workflows, Obsidian vault)
│   ├── cheatsheets/
│   ├── workflows/
│   └── Obsidian Vault/           # Tracked vault; plugin configs versioned under .obsidian/
├── tools/
│   ├── configs/                  # Shared linting/formatting configs (eslint, prettier, editorconfig)
│   ├── llms-prompt-examples/     # LLM prompt reference material
│   ├── scripts/                  # Workspace automation scripts
│   ├── sonarqube/                # Docker Compose stack for local code quality runs
│   └── templates/                # Project scaffolding templates (web-app: Vite+React+TS)
├── projects/                     # git-ignored — local active projects
└── scratch/                      # git-ignored — experiments and throwaway work
```

- `projects/` and `scratch/` are git-ignored. Do not commit artifacts from those paths without a deliberate `.gitignore` change.
- Add knowledge-base content under `docs/cheatsheets/` or `docs/workflows/`; cross-link between documents where useful.
- Place new versioned utilities under a dedicated `tools/<name>/` subdirectory.

## Build, Test, and Development Commands

### Workspace Automation
```bash
bash tools/scripts/workspace-setup.sh          # Initialize and configure the workspace
bash tools/scripts/workspace-setup.sh --help   # Show setup options

bash tools/scripts/workspace-health.sh         # Check workspace status and health
bash tools/scripts/workspace-health.sh --help

bash tools/scripts/backup.sh                   # Backup projects/ and scratch/
bash tools/scripts/backup.sh --help
```

### Shell Script Validation (run before every commit)
```bash
bash -n tools/scripts/workspace-setup.sh       # Syntax check a single script
shellcheck tools/scripts/workspace-setup.sh    # Lint a single script (if shellcheck installed)

# Validate all scripts at once
for f in tools/scripts/*.sh tools/sonarqube/scripts/*.sh; do
  bash -n "$f" && echo "OK: $f"
done
```

### SonarQube (Docker Compose)
```bash
# Validate config before starting
docker-compose -f tools/sonarqube/docker-compose.yml config

docker-compose -f tools/sonarqube/docker-compose.yml up -d        # Start (detached)
docker-compose -f tools/sonarqube/docker-compose.yml logs -f      # Tail logs
docker-compose -f tools/sonarqube/docker-compose.yml ps           # Check status
docker-compose -f tools/sonarqube/docker-compose.yml restart      # Restart service
docker-compose -f tools/sonarqube/docker-compose.yml down         # Stop and remove containers
docker-compose -f tools/sonarqube/docker-compose.yml down -v      # Wipe containers + volumes (destructive)

# Manager script (must be run from tools/sonarqube/scripts/ or update COMPOSE_FILE inside)
bash tools/sonarqube/scripts/sonarqube-manager.sh start|stop|status
```
SonarQube runs on port `9000`; default credentials are `admin/admin`. Allow 2–3 minutes for startup.

### Web App Template (tools/templates/web-app)
```bash
npm run dev          # Start Vite dev server
npm run build        # Production build
npm run preview      # Preview production build
npm test             # Run all Vitest tests
npm run test -- path/to/file.test.ts   # Run a single test file
npm run lint         # ESLint check
npm run lint:fix     # ESLint auto-fix
npm run format       # Prettier format
```

## Coding Style & Naming Conventions

### Shell Scripts
- **Shebang and safety flags** — every script must open with:
  ```bash
  #!/bin/bash
  set -euo pipefail
  ```
- **Constants** — declare with `readonly`; never use bare assignments for config values:
  ```bash
  readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  readonly WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
  readonly SONARQUBE_PORT="${SONARQUBE_PORT:-9000}"   # env override pattern
  ```
- **Indentation** — four spaces (no tabs in shell scripts).
- **File names** — lowercase with hyphens: `workspace-setup.sh`, `sonarqube-manager.sh`.
- **Function names** — `snake_case`, verb-prefixed: `check_requirements`, `setup_directory_structure`, `create_backup`, `show_help`.
- **Logging** — use a unified `log "LEVEL" "message"` function with color codes:
  ```bash
  log() {
      local level="$1"; shift
      local message="$*"
      case "$level" in
          INFO)  echo -e "${GREEN}[INFO]${NC} $message" ;;
          WARN)  echo -e "${YELLOW}[WARN]${NC} $message" ;;
          ERROR) echo -e "${RED}[ERROR]${NC} $message" ;;
          DEBUG) echo -e "${BLUE}[DEBUG]${NC} $message" ;;
      esac
  }
  ```
- **Entry point** — wrap all execution in `main()` called at the bottom with `main "$@"`.
- **Argument parsing** — use `while [[ $# -gt 0 ]]; do case "$1" in ... esac; shift; done` inside `main`.
- **Arrays** — use bash arrays for collecting validation failures:
  ```bash
  local missing=()
  command -v git >/dev/null 2>&1 || missing+=("git")
  [[ ${#missing[@]} -gt 0 ]] && { log "ERROR" "Missing: ${missing[*]}"; exit 1; }
  ```
- **Exit codes** — `exit 0` success, `exit 1` general failure, `exit 2` invalid args, `exit 3` Docker/dependency unavailable.
- **Secrets** — never hardcode credentials; read from environment variables with `${VAR:?must be set}`.

### Markdown
- ATX headers (`#`, `##`, `###`) — no Setext underline headers.
- Fenced code blocks with explicit language tags: ` ```bash `, ` ```json `, ` ```yaml `.
- Unordered bullets use hyphens (`-`), never asterisks or plus signs.
- Numbered lists for sequential steps only.
- Two-space indent for nested bullets.
- Inline code with single backticks for commands, paths, and tool names.
- Short sections; bullets over dense paragraphs; cross-link related docs.
- Trailing whitespace is preserved in Markdown (`.editorconfig` sets `trim_trailing_whitespace = false` for `.md`).

### JavaScript / TypeScript (web-app template)
Config lives in `tools/configs/`; key rules:
- **Prettier** — `singleQuote: true`, `semi: true`, `tabWidth: 2`, `trailingComma: 'es5'`, `printWidth: 80`, `arrowParens: 'avoid'`.
- **ESLint** — extends `eslint:recommended` + `@typescript-eslint/recommended`; `eqeqeq: always`, `prefer-const`, `no-var`, `no-eval`, `no-console: warn`.
- Use TypeScript strict mode; avoid `any` outside test files.
- React hooks rules enforced (`react-hooks/rules-of-hooks`, `react-hooks/exhaustive-deps`).

### YAML / Docker Compose
- Two-space indentation.
- No `version:` key (modern Compose format).
- Use named volumes, not bind mounts, for stateful services.
- Always pass `-f` with the explicit path when invoking `docker-compose`.

### EditorConfig Defaults
- Charset: `utf-8`, line endings: `lf`, final newline: `true`.
- Default indent: 2 spaces (override: 4 for Python, tabs for Go and Makefiles, CRLF for `.bat/.cmd`).

## Testing Guidelines

- **Syntax check** every shell script with `bash -n` before committing.
- **Lint** with `shellcheck` where available; fix all warnings unless explicitly documented.
- **Smoke-test** scripts by running `--help` first; then run against a safe test path.
- **Docker Compose** — always run `docker-compose config` to validate YAML before `up`.
- **Down-with-volumes** (`down -v`) is destructive and wipes all SonarQube data; document this in PR notes when done intentionally.
- No formal coverage targets; describe manual verification steps in your PR description.

## Commit & Pull Request Guidelines

- Conventional commits in imperative mood: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.
- Subject line: brief (under 72 chars), no trailing period.
- PR description must include: scope of change, commands run (including validation), and data impact (e.g., volume resets, `.gitignore` changes).
- Attach screenshots for any UI or visual changes.
- Never commit from `projects/` or `scratch/` without an explicit `.gitignore` update and rationale.
- Keep Docker volumes and workspace-generated files (`.setup.log`, `.workspace-config`, `.workspace-health`) out of the repository.
