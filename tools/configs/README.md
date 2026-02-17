# Shared Configurations

This directory contains shared configuration files that can be used across multiple projects in the workspace.

## Available Configurations

### Development Tools
- **eslint** - JavaScript/TypeScript linting rules
- **prettier** - Code formatting configuration
- **editorconfig** - Editor settings for consistent formatting
- **gitignore** - Common Git ignore patterns for different project types

### Testing
- **jest** - JavaScript testing configuration
- **vitest** - Vite-based testing configuration  
- **cypress** - End-to-end testing configuration

### Build Tools
- **vite** - Modern build tool configuration
- **webpack** - Module bundler configuration
- **rollup** - JavaScript library bundler configuration

### Code Quality
- **sonarqube** - Code quality analysis configuration
- **commitlint** - Commit message linting rules
- **husky** - Git hooks configuration

## Using Configurations

### Copy to Project
```bash
cp tools/configs/eslint/.eslintrc.js projects/my-project/
cp tools/configs/prettier/.prettierrc projects/my-project/
```

### Symlink (for shared updates)
```bash
ln -s ../../tools/configs/eslint/.eslintrc.js projects/my-project/
```

### Extend in Project
```json
{
  "extends": ["../../tools/configs/eslint/.eslintrc.js"]
}
```

## Configuration Guidelines

### File Organization
- Each config type has its own directory
- Include both configuration files and documentation
- Provide examples of usage

### Naming Convention
- Use standard config file names (`.eslintrc.js`, `.prettierrc`, etc.)
- Include `README.md` in each config directory
- Use descriptive directory names

### Content Guidelines
- **Generic and reusable** - Avoid project-specific settings
- **Well documented** - Explain configuration choices
- **Extensible** - Allow projects to override settings
- **Up to date** - Keep configurations current with best practices

## Configuration Types

### Linting Configurations
Purpose: Enforce code quality and consistency
- ESLint for JavaScript/TypeScript
- Stylelint for CSS/SCSS
- Markdownlint for documentation

### Formatting Configurations  
Purpose: Automatic code formatting
- Prettier for code formatting
- EditorConfig for editor settings

### Testing Configurations
Purpose: Standardize testing setup
- Jest for unit testing
- Vitest for Vite projects
- Cypress for E2E testing

### Build Configurations
Purpose: Standardize build processes
- Vite for modern web projects
- Webpack for complex bundling
- Rollup for libraries

## Best Practices

### When to Share Configurations
- ✅ Common linting rules across projects
- ✅ Standard formatting preferences
- ✅ Base testing configurations
- ✅ Common build patterns

### When to Keep Project-Specific
- ❌ Framework-specific settings
- ❌ Project-specific build outputs
- ❌ Custom plugin configurations
- ❌ Environment-specific settings

### Maintenance
- Review configurations quarterly
- Update dependencies regularly
- Test configurations with real projects
- Document breaking changes