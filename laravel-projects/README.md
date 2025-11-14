# Laravel Projects - Centralized Management

**Centralized system for managing shared Laravel project configurations, documentation, workflows, and tools.**

This directory contains multiple Laravel projects that share common setup, documentation, and tooling. All shared resources are centralized here to eliminate duplication and ensure consistency.

---

## Quick Start

### For New Projects

```bash
cd /path/to/new-laravel-project
/path/to/laravel-projects/scripts/setup-laravel-project.sh
```

This interactive wizard will:
- Install pre-commit hooks
- Set up GitHub workflow templates
- Install configuration templates
- Create documentation links

### For Existing Projects

```bash
cd /path/to/existing-laravel-project
/path/to/laravel-projects/scripts/update-laravel-project.sh
```

This will sync updates from the central location.

---

## Directory Structure

```
laravel-projects/
├── docs/                          # Centralized documentation
│   ├── README.md                  # Documentation index
│   ├── sentry/                    # Sentry setup guides
│   ├── telescope/                 # Telescope setup guides
│   ├── coderabbit/                # CodeRabbit setup guides
│   ├── git/                       # Git workflows and hooks
│   └── code-quality/              # Code quality standards
├── .github-templates/             # GitHub workflow and config templates
│   ├── workflows/                 # Workflow templates
│   └── *.template                 # Config file templates
├── scripts/                       # Management scripts
│   ├── setup-laravel-project.sh   # New project setup wizard
│   ├── update-laravel-project.sh  # Update existing projects
│   ├── install-github-templates.sh # Install workflow templates
│   ├── install-pre-commit-hook.sh # Install pre-commit hook
│   └── pre-commit-hook.sh         # Master pre-commit hook
├── Moveroo-Cars-2026/            # Project 1
├── Moveroo Removals 2026/        # Project 2
├── console-analytics/             # Project 3
└── [other projects...]
```

---

## Documentation

All shared documentation is in the `docs/` directory:

- **[Documentation Index](docs/README.md)** - Overview and quick links
- **[Sentry Setup](docs/sentry/SETUP.md)** - Error tracking and monitoring
- **[Telescope Setup](docs/telescope/SETUP.md)** - Debugging and monitoring
- **[CodeRabbit Setup](docs/coderabbit/SETUP.md)** - AI code review
- **[Git Workflows](docs/git/WORKFLOWS.md)** - GitHub Actions workflows
- **[Pre-Commit Hooks](docs/git/PRE-COMMIT-HOOKS.md)** - Code quality checks
- **[Code Quality Standards](code-quality-standards-guide.md)** - PHPStan, Pint, etc.

---

## Available Scripts

### Setup Scripts

- **`scripts/setup-laravel-project.sh`** - Interactive wizard for new projects
- **`scripts/update-laravel-project.sh`** - Sync updates to existing projects

### Installation Scripts

- **`scripts/install-github-templates.sh`** - Install workflow templates
- **`scripts/install-pre-commit-hook.sh`** - Install pre-commit hook

### Master Files

- **`scripts/pre-commit-hook.sh`** - Master pre-commit hook (source of truth)

---

## Templates

### Workflow Templates

Located in `.github-templates/workflows/`:

- **`auto-pr-dev-to-main.yml.template`** - Auto-create PR from dev to main

### Config Templates

Located in `.github-templates/`:

- **`.coderabbit.yaml.template`** - CodeRabbit configuration

---

## Projects

Current Laravel projects in this directory:

1. **Moveroo-Cars-2026** - Vehicle transport management
2. **Moveroo Removals 2026** - Removalist services
3. **console-analytics** - Analytics console

---

## Key Principles

1. **Single Source of Truth**: One master version of each shared resource
2. **Project-Specific Override**: Projects can customize after installation
3. **Easy Updates**: Scripts to sync updates from central location
4. **Documentation First**: Comprehensive guides before implementation
5. **Backward Compatible**: Don't break existing projects during migration

---

## What Gets Centralized

- ✅ Setup guides (Sentry, Telescope, CodeRabbit)
- ✅ Workflow templates
- ✅ Pre-commit hooks
- ✅ Code quality standards
- ✅ Git configuration templates
- ✅ Management scripts

## What Stays Project-Specific

- ❌ `composer.json` / `package.json` dependencies
- ❌ Database configurations
- ❌ Application-specific code
- ❌ Project-specific documentation (business logic, features)
- ❌ Environment variables (`.env` files)

---

## Migration Guide

For migrating existing projects to use centralized resources, see:

**[Migration Guide](docs/MIGRATION-GUIDE.md)**

---

## Contributing

When updating shared resources:

1. **Update the master file** in `laravel-projects/`
2. **Test in one project** first
3. **Run update script** on other projects: `scripts/update-laravel-project.sh`
4. **Update documentation** if needed
5. **Commit changes** to all affected projects

---

## Related Resources

- [Centralized Laravel Management Discussion](CENTRALIZED_LARAVEL_MANAGEMENT_DISCUSSION.md)
- [Code Quality Standards Guide](code-quality-standards-guide.md)
- [Baseline Tracking](BASELINE-TRACKING.md)

## Quick Links to Centralized Documentation

- **[Documentation Index](docs/README.md)** - Complete documentation overview
- **[Sentry Setup](docs/sentry/SETUP.md)** - Error tracking setup
- **[Telescope Setup](docs/telescope/SETUP.md)** - Debugging tool setup
- **[CodeRabbit Setup](docs/coderabbit/SETUP.md)** - AI code review setup
- **[Migration Guide](docs/MIGRATION-GUIDE.md)** - Migrate existing projects

---

**Last Updated:** 2025-01-XX

