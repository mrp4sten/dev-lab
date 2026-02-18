# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Project Structure

```
{{PROJECT_NAME}}/
├── src/               # Source code
├── tests/             # Test suites
├── docs/              # Project documentation
└── package.json       # or equivalent dependency config
```

- Describe each top-level directory's purpose in one line.
- Call out any non-obvious conventions (e.g., co-located tests, monorepo boundaries).
- List paths that are git-ignored and must never be committed.

## Build, Test, and Development Commands

```bash
# Install dependencies
{{INSTALL_COMMAND}}           # e.g. npm install / bun install / pip install -r requirements.txt

# Development
{{DEV_COMMAND}}               # e.g. npm run dev / bun dev

# Build
{{BUILD_COMMAND}}             # e.g. npm run build / bun run build

# Run all tests
{{TEST_COMMAND}}              # e.g. npm test / bun test / pytest

# Run a single test file
{{SINGLE_TEST_COMMAND}}       # e.g. npm run test -- path/to/file.test.ts / pytest path/to/test_file.py

# Lint
{{LINT_COMMAND}}              # e.g. npm run lint / ruff check .

# Format
{{FORMAT_COMMAND}}            # e.g. npm run format / ruff format .

# Type check
{{TYPECHECK_COMMAND}}         # e.g. bun run typecheck / mypy src/
```

## Code Standards

- Specify the language version and strictness level (e.g., TypeScript strict mode, Python 3.12+).
- Avoid `any` / untyped code; use proper types or type narrowing.
- Prefer named exports over default exports (adjust per language/framework conventions).
- Keep functions small and single-purpose; delegate logic to shared modules.

### Imports

```ts
// Describe the import order and grouping convention, e.g.:
// 1. Standard library
// 2. Third-party packages
// 3. Internal/workspace packages (use package names, never relative cross-package paths)
// 4. Relative imports within the same module
```

### Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Files & directories | `kebab-case` | `user-service.ts` |
| Classes & types | `PascalCase` | `UserService` |
| Functions & variables | `camelCase` | `getUserById` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Test files | same name + `.test` | `user-service.test.ts` |

### Formatting

- Describe formatter and key settings (e.g., Prettier, `singleQuote: true`, `tabWidth: 2`).
- Note any per-language overrides.
- State whether formatting is enforced in CI or pre-commit hooks.

### Error Handling

- Describe the expected error handling strategy (exceptions, Result types, error codes, etc.).
- Specify where errors should be caught and how they should be logged.
- Note any structured logging requirements (fields, format, log levels).

## Testing Guidelines

- Describe where tests live relative to source files (co-located vs. separate `tests/` dir).
- Specify the test runner and any required setup.
- State how to run a single test file or a single test case.
- List what must be mocked (e.g., external APIs, databases, cloud SDKs).
- Note any coverage requirements or targets.

## Commit & Pull Request Guidelines

- Use conventional commits in imperative mood: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.
- Subject line: brief (under 72 chars), no trailing period.
- PR description must include: scope of change, commands run (tests, linting), and any infrastructure or data impact.
- Never commit secrets, credentials, or generated build artifacts.
- List any files/directories that must always stay out of the repo.
