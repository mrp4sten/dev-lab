# Project Templates

This directory contains templates for quickly bootstrapping new projects and components.

## Available Templates

### Project Templates
- **web-app** - Modern web application (Vite + React + TypeScript + Vitest)
- **api-service** - REST API service template *(planned)*
- **cli-tool** - Command-line tool template *(planned)*
- **library** - Reusable library template *(planned)*
- **fullstack** - Full-stack application template *(planned)*

### Agent & AI Templates
- **AGENTS-template.md** - Generic template for writing `AGENTS.md` files for any project

### Component Templates
- **component** - Generic component template
- **service** - Service class template
- **model** - Data model template
- **test** - Test suite template

## Using Templates

### Manual Copy
```bash
cp -r tools/templates/web-app projects/my-new-app
cd projects/my-new-app
# Customize as needed
```

### With Template Script (Future)
```bash
./tools/scripts/create-project.sh web-app my-new-app
```

## Template Structure

Each template should include:
- **README.md** - Project-specific documentation
- **package.json** or equivalent - Dependency configuration
- **.gitignore** - Appropriate ignore patterns
- **src/** - Source code structure
- **tests/** - Test structure
- **docs/** - Template documentation

## Contributing Templates

When adding new templates:

1. **Keep them generic** - Avoid project-specific details
2. **Include documentation** - README with setup instructions
3. **Use placeholders** - `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, etc.
4. **Test thoroughly** - Ensure template works standalone
5. **Follow conventions** - Match existing template patterns

## Template Guidelines

### File Naming
- Use lowercase with hyphens for directories
- Include descriptive README files
- Use appropriate file extensions

### Content
- Include comprehensive .gitignore
- Add basic documentation structure
- Provide example code and tests
- Include build/development scripts

### Customization
- Use clear placeholder syntax: `{{VARIABLE}}`
- Document all placeholders in template README
- Provide sensible defaults where possible

## Template Variables

Common placeholders used across templates:
- `{{PROJECT_NAME}}` - Project name
- `{{DESCRIPTION}}` - Project description  
- `{{AUTHOR}}` - Author name
- `{{EMAIL}}` - Author email
- `{{YEAR}}` - Current year
- `{{LICENSE}}` - License type