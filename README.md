# 🧪 Dev-Lab | Digital Workspace

![Workspace Status](https://img.shields.io/badge/status-active-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Tools](https://img.shields.io/badge/tools-docker%20%7C%20sonarqube-blue)
![Projects](https://img.shields.io/badge/dynamic/json?color=orange&label=projects&query=$.projects&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fmrp4sten%2Fdev-lab%2Fcontents%2F.workspace-health&logo=github&logoColor=white&fallback=3)

> **"Code fast, deploy faster"** 🚀

## 🚀 Quick Start

```bash
# Setup workspace
./tools/scripts/workspace-setup.sh

# Check workspace health  
./tools/scripts/workspace-health.sh

# Create backup
./tools/scripts/backup.sh
```

## 📁 Core Structure

### 🔧 **Development Zones**

| Directory | Purpose | Status |
|-----------|---------|---------|
| `projects/` | Active code projects & apps | 🚧 *gitignored* |
| `scratch/`  | Experiments & quick tests | 🧪 *gitignored* |
| `tools/`    | Dev tools & services | ⚡ **versioned** |

### 📚 **Knowledge Base**

| Directory | Content |
|-----------|---------|
| `cheatsheets/` | Quick commands & references |
| `workflows/`   | Automation & CI/CD guides |

### ⚙️ **Automation & Tools**

| Directory | Purpose |
|-----------|---------|
| `scripts/` | Workspace automation & management |
| `templates/` | Project scaffolding templates |
| `configs/` | Shared configuration files |

## 🎯 Quick Use

- **New project?** → `projects/your-app/`
- **Quick test?** → `scratch/experiment/`
- **Need tools?** → `tools/sonarqube/`
- **Document?** → `docs/cheatsheets/`
- **Check health?** → `./tools/scripts/workspace-health.sh`

## 📊 Workspace Health

Run the health dashboard to monitor your workspace:

```bash
./tools/scripts/workspace-health.sh          # One-time check
./tools/scripts/workspace-health.sh --watch  # Continuous monitoring
```

> *Built for developers, by developers* 💻✨
