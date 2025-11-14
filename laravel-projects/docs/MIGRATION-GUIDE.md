# Migration Guide

**Purpose:** Step-by-step guide for migrating existing Laravel projects to use centralized configurations.

---

## Overview

This guide helps you migrate existing Laravel projects to use the centralized management system. The migration process is designed to be non-destructive and allows you to keep project-specific customizations.

---

## Pre-Migration Checklist

Before starting, ensure:

- [ ] You have a backup of your project
- [ ] You're on a feature branch (not main/master)
- [ ] You understand what will be changed
- [ ] You have commit access to the repository

---

## Migration Steps

### Step 1: Backup Current Configurations

```bash
cd /path/to/your-laravel-project

# Backup existing files
mkdir -p .backup-$(date +%Y%m%d)
cp .git/hooks/pre-commit .backup-$(date +%Y%m%d)/pre-commit 2>/dev/null || true
cp -r .github/workflows .backup-$(date +%Y%m%d)/workflows 2>/dev/null || true
cp .coderabbit.yaml .backup-$(date +%Y%m%d)/.coderabbit.yaml 2>/dev/null || true
```

### Step 2: Install Pre-Commit Hook

```bash
/path/to/laravel-projects/scripts/install-pre-commit-hook.sh --force
```

**What this does:**
- Replaces existing pre-commit hook with master version
- Backs up existing hook automatically
- Makes hook executable

**Verify:**
```bash
# Test the hook
git commit --dry-run
```

### Step 3: Install Workflow Templates

```bash
/path/to/laravel-projects/scripts/install-github-templates.sh \
  --base-branch main \
  --head-branch dev \
  --project-name YourProjectName
```

**What this does:**
- Copies workflow templates to `.github/workflows/`
- Replaces template variables with your project values
- Backs up existing workflows

**Customize:**
After installation, review and customize `.github/workflows/auto-pr-dev-to-main.yml` if needed.

### Step 4: Install Config Templates

The setup script will also install config templates. Or manually:

```bash
# Install .coderabbit.yaml
cp /path/to/laravel-projects/.github-templates/.coderabbit.yaml.template .coderabbit.yaml
```

**Review and customize** the config file as needed for your project.

### Step 5: Create Documentation Link

```bash
# Create README-SETUP.md pointing to centralized docs
cat > README-SETUP.md << 'EOF'
# Setup Documentation

This project uses centralized setup documentation.

See [../docs/README.md](../docs/README.md) for complete documentation index.
EOF
```

### Step 6: Test Everything

```bash
# Test pre-commit hook
git add .
git commit --dry-run

# Verify workflows exist
ls -la .github/workflows/

# Check configs
ls -la .coderabbit.yaml
```

### Step 7: Commit Changes

```bash
git add .
git commit -m "chore: migrate to centralized Laravel project management"
```

### Step 8: Push and Verify

```bash
git push origin your-branch

# Verify GitHub Actions workflow runs
# Check that PR is created correctly (if using auto-PR workflow)
```

---

## What Gets Replaced

### Pre-Commit Hook

- **Replaced:** `.git/hooks/pre-commit`
- **Backed up:** Automatically with timestamp
- **Customizable:** Yes, after installation

### Workflow Templates

- **Replaced:** `.github/workflows/auto-pr-dev-to-main.yml` (if exists)
- **Backed up:** Automatically with timestamp
- **Customizable:** Yes, after installation

### Config Templates

- **Replaced:** `.coderabbit.yaml` (if exists)
- **Backed up:** Automatically with timestamp
- **Customizable:** Yes, after installation

---

## What Stays Project-Specific

These files remain project-specific and are NOT replaced:

- `composer.json` / `package.json`
- `config/` directory files
- `routes/` files
- `app/` directory (application code)
- `.env` files
- Project-specific documentation

---

## Handling Conflicts

### If Pre-Commit Hook Has Custom Changes

1. **Review differences:**
   ```bash
   diff .backup-YYYYMMDD/pre-commit /path/to/laravel-projects/scripts/pre-commit-hook.sh
   ```

2. **Merge customizations:**
   - Install master hook
   - Manually add your customizations back
   - Document customizations for future reference

### If Workflow Has Custom Changes

1. **Review differences:**
   ```bash
   diff .backup-YYYYMMDD/workflows/auto-pr-dev-to-main.yml \
        .github/workflows/auto-pr-dev-to-main.yml
   ```

2. **Merge customizations:**
   - Keep your custom changes
   - Update template variables if needed
   - Test the workflow

---

## Rollback

If you need to rollback:

```bash
# Restore pre-commit hook
cp .backup-YYYYMMDD/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Restore workflows
cp -r .backup-YYYYMMDD/workflows/* .github/workflows/

# Restore configs
cp .backup-YYYYMMDD/.coderabbit.yaml .coderabbit.yaml
```

---

## Post-Migration

### Update Documentation

1. Remove project-specific setup docs that are now centralized
2. Add link to centralized docs (README-SETUP.md)
3. Update any internal documentation references

### Verify Integration

1. **Test pre-commit hook:**
   ```bash
   git commit --dry-run
   ```

2. **Test workflow:**
   - Push to dev branch
   - Verify PR is created
   - Check CodeRabbit reviews it

3. **Test configs:**
   - Verify CodeRabbit configuration works
   - Check workflow permissions

---

## Keeping Up to Date

After migration, keep your project updated:

```bash
# Check for updates
/path/to/laravel-projects/scripts/update-laravel-project.sh

# Apply updates
/path/to/laravel-projects/scripts/update-laravel-project.sh --auto-apply
```

Run this periodically to sync updates from the central location.

---

## Troubleshooting

### "Script not found" Error

Ensure you're using absolute paths or the script is in your PATH:

```bash
# Use absolute path
/path/to/laravel-projects/scripts/install-pre-commit-hook.sh

# Or add to PATH
export PATH="$PATH:/path/to/laravel-projects/scripts"
```

### "Not a git repository" Error

Ensure you're in the project root:

```bash
cd /path/to/laravel-project
# Should see artisan file
ls artisan
```

### Hook Not Running After Installation

1. Check if executable:
   ```bash
   chmod +x .git/hooks/pre-commit
   ```

2. Test manually:
   ```bash
   .git/hooks/pre-commit
   ```

### Workflow Not Triggering

1. Check workflow file exists: `.github/workflows/auto-pr-dev-to-main.yml`
2. Check branch name matches workflow trigger
3. Verify GitHub Actions is enabled for the repository

---

## Best Practices

1. **Migrate on feature branch** - Don't migrate directly on main
2. **Test thoroughly** - Verify everything works before merging
3. **Keep backups** - The scripts backup automatically, but keep your own too
4. **Document customizations** - Note any project-specific changes
5. **Update regularly** - Use update script to stay current

---

## Quick Migration (Automated)

For a quick automated migration:

```bash
cd /path/to/your-laravel-project

# Run setup script (will prompt for options)
/path/to/laravel-projects/scripts/setup-laravel-project.sh
```

This interactive wizard handles everything automatically.

---

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review the specific documentation:
   - [Pre-Commit Hooks](git/PRE-COMMIT-HOOKS.md)
   - [Git Workflows](git/WORKFLOWS.md)
   - [CodeRabbit Setup](coderabbit/SETUP.md)
3. Check backup files for original configurations

---

**Last Updated:** 2025-01-XX

