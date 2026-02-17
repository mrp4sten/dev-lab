# Gitignore Templates

This directory contains common .gitignore templates for different project types and technologies.

## Available Templates

### Language-Specific
- **node.gitignore** - Node.js and JavaScript projects
- **python.gitignore** - Python applications
- **java.gitignore** - Java and Spring Boot projects
- **go.gitignore** - Go applications
- **rust.gitignore** - Rust projects

### Framework-Specific
- **react.gitignore** - React applications
- **nextjs.gitignore** - Next.js projects
- **vue.gitignore** - Vue.js applications
- **angular.gitignore** - Angular projects
- **django.gitignore** - Django applications

### Tool-Specific
- **docker.gitignore** - Docker-related ignores
- **vscode.gitignore** - VS Code editor files
- **jetbrains.gitignore** - IntelliJ/PyCharm files
- **mac.gitignore** - macOS system files
- **windows.gitignore** - Windows system files

## Using Templates

### Copy to Project
```bash
cp tools/configs/gitignore/node.gitignore projects/my-app/.gitignore
```

### Combine Templates
```bash
cat tools/configs/gitignore/node.gitignore tools/configs/gitignore/vscode.gitignore > projects/my-app/.gitignore
```

### Add to Existing
```bash
cat tools/configs/gitignore/docker.gitignore >> projects/my-app/.gitignore
```

## Template Guidelines

When adding new templates:

1. **Use descriptive names** - Include technology or purpose in filename
2. **Keep them comprehensive** - Include common ignore patterns
3. **Document sections** - Use comments to explain pattern groups
4. **Test patterns** - Verify they work in real projects
5. **Update regularly** - Keep current with tool changes

## Common Patterns

### Always Include
```gitignore
# Dependencies
node_modules/
.pnp.*

# Logs
*.log
logs/

# Environment variables
.env*

# OS files
.DS_Store
Thumbs.db
```

### Build Outputs
```gitignore
# Build directories
dist/
build/
out/

# Cache directories
.cache/
.parcel-cache/
.next/
```

### IDE Files
```gitignore
# VS Code
.vscode/

# JetBrains
.idea/

# Vim
*.swp
*.swo
```