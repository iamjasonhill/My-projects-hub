# Laravel Projects Documentation

**Centralized documentation for all Laravel projects in this repository.**

This directory contains shared setup guides, configuration templates, and best practices that apply to all Laravel projects.

---

## Quick Links

### Setup Guides

- **[Sentry Setup](sentry/SETUP.md)** - Error tracking and performance monitoring
  - [404 Error Reporting](sentry/404-REPORTING.md) - Configure 404 reporting with bot filtering
  - [CLI & Error Checking](sentry/CLI.md) - Command-line tools for checking errors
  - [Production Setup](sentry/PRODUCTION.md) - Quick production deployment guide

- **[Telescope Setup](telescope/SETUP.md)** - Debugging and monitoring tool

- **[CodeRabbit Setup](coderabbit/SETUP.md)** - AI-powered code review
  - [Cursor Integration](coderabbit/CURSOR-INTEGRATION.md) - Integrating with Cursor IDE
  - [PR Workflow](coderabbit/PR-WORKFLOW.md) - Configuring automatic PR reviews

### Git & Workflows

- **[Git Workflows](git/WORKFLOWS.md)** - GitHub Actions workflow templates and setup
- **[Pre-Commit Hooks](git/PRE-COMMIT-HOOKS.md)** - Automated code quality checks

### Code Quality

- **[Code Quality Standards](../code-quality-standards-guide.md)** - PHPStan, Pint, and pre-commit setup

---

## Documentation Structure

```
docs/
├── README.md (this file)
├── sentry/
│   ├── SETUP.md
│   ├── 404-REPORTING.md
│   ├── CLI.md
│   └── PRODUCTION.md
├── telescope/
│   └── SETUP.md
├── coderabbit/
│   ├── SETUP.md
│   ├── CURSOR-INTEGRATION.md
│   └── PR-WORKFLOW.md
├── git/
│   ├── WORKFLOWS.md
│   └── PRE-COMMIT-HOOKS.md
└── code-quality/
    └── (references to ../code-quality-standards-guide.md)
```

---

## Project-Specific Notes

While these guides are project-agnostic, some projects may have specific configurations:

- **Moveroo-Cars-2026**: Reference implementation for most setups
- **Moveroo Removals 2026**: Uses same configurations with project-specific customizations
- **console-analytics**: May have different requirements

---

## Getting Started

1. **New Project Setup**: See [Migration Guide](MIGRATION-GUIDE.md) for step-by-step instructions
2. **Existing Projects**: Use the update scripts to sync from central location
3. **Specific Tools**: Navigate to the relevant setup guide above

---

## Contributing

When updating documentation:

1. **Keep it project-agnostic**: Remove project-specific references
2. **Update all relevant files**: If a tool changes, update all related docs
3. **Test instructions**: Verify all commands and steps work
4. **Link related docs**: Cross-reference related documentation

---

## Related Resources

- [Centralized Laravel Management Discussion](../CENTRALIZED_LARAVEL_MANAGEMENT_DISCUSSION.md)
- [Code Quality Standards Guide](../code-quality-standards-guide.md)
- [Baseline Tracking](../BASELINE-TRACKING.md)

---

**Last Updated:** 2025-01-XX

