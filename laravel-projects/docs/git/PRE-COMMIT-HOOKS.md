# Pre-Commit Hooks Documentation

**Purpose:** Documentation for the centralized pre-commit hook system.

---

## Overview

The pre-commit hook runs automated code quality checks before allowing commits. This ensures consistent code quality across all Laravel projects.

---

## What the Hook Does

The master pre-commit hook (`scripts/pre-commit-hook.sh`) performs these checks:

1. **Laravel Pint** - Auto-fixes code style issues
2. **PHP Syntax Check** - Validates PHP syntax
3. **Blade Syntax Check** - Checks for unmatched directives (@if/@endif, etc.)
4. **Missing Includes Check** - Verifies @include directives reference existing files
5. **Codacy Compliance** - Checks code quality rules
6. **Blade Property Access** - Validates safe property access in Blade templates
7. **Dark Mode Compliance** - Checks Tailwind dark mode classes
8. **PHPStan** - Disabled (runs in CI/CD instead)
9. **CodeRabbit** - Optional AI code review (disabled by default)

---

## Installation

### Using the Install Script (Recommended)

```bash
cd /path/to/laravel-project
/path/to/laravel-projects/scripts/install-pre-commit-hook.sh
```

**Options:**
- `--force` - Overwrite existing hook
- `--dry-run` - Show what would be done without making changes

### Manual Installation

```bash
cd /path/to/laravel-project
cp /path/to/laravel-projects/scripts/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

---

## Updating the Hook

To update an existing hook with the latest version:

```bash
cd /path/to/laravel-project
/path/to/laravel-projects/scripts/install-pre-commit-hook.sh --force
```

Or use the update script:

```bash
cd /path/to/laravel-project
/path/to/laravel-projects/scripts/update-laravel-project.sh
```

---

## Customization

After installation, you can customize the hook in `.git/hooks/pre-commit`:

### Disable Specific Checks

Comment out sections you don't need:

```bash
# 5. Codacy Compliance Check
# echo -e "${BLUE}5. Checking Codacy compliance...${NC}"
# ... (entire section commented out)
```

### Enable CodeRabbit Pre-Commit

Set environment variable:

```bash
export ENABLE_CODERABBIT_PRE_COMMIT=true
git commit -m "Your message"
```

Or add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export ENABLE_CODERABBIT_PRE_COMMIT=true
```

---

## Troubleshooting

### Hook Not Running

1. **Check if hook exists:**
   ```bash
   ls -la .git/hooks/pre-commit
   ```

2. **Check if executable:**
   ```bash
   chmod +x .git/hooks/pre-commit
   ```

3. **Test manually:**
   ```bash
   .git/hooks/pre-commit
   ```

### Hook Blocks All Commits

If the hook is too strict:

1. **Fix the issues** (recommended)
2. **Temporarily bypass** (use carefully):
   ```bash
   git commit --no-verify -m "Emergency fix"
   ```

3. **Disable specific checks** in the hook file

### Hook Too Slow

The hook is optimized to run quickly:
- Only checks staged files
- PHPStan is disabled (runs in CI/CD)
- CodeRabbit is optional and disabled by default

If still slow:
- Check only critical files
- Disable optional checks
- Run PHPStan/CodeRabbit manually instead

### "Permission denied" Error

```bash
chmod +x .git/hooks/pre-commit
```

---

## Required Tools

The hook uses these tools (install if missing):

- **Laravel Pint**: `composer require --dev laravel/pint`
- **Codacy Compliance**: Create artisan command `check:codacy-compliance`
- **Blade Property Checker**: Create artisan command `check:blade-properties`
- **Dark Mode Checker**: `check-dark-mode.sh` script (optional)

---

## Best Practices

1. **Fix issues immediately** - Don't bypass the hook
2. **Run checks manually** - Use individual commands to debug
3. **Keep hook updated** - Sync from central location regularly
4. **Customize carefully** - Document any project-specific changes

---

## Manual Check Commands

If you want to run checks manually:

```bash
# Code style
./vendor/bin/pint --test app/

# PHP syntax
php -l app/Http/Controllers/YourController.php

# Codacy compliance
php artisan check:codacy-compliance app/Http/Controllers/YourController.php

# Blade syntax (check manually)
grep -c '@if' resources/views/file.blade.php
grep -c '@endif' resources/views/file.blade.php

# Dark mode
./check-dark-mode.sh resources/views/
```

---

## Resources

- [Code Quality Standards Guide](../../code-quality-standards-guide.md)
- [Laravel Pint Documentation](https://laravel.com/docs/pint)
- [Codacy Documentation](https://docs.codacy.com/)

---

**Last Updated:** 2025-01-XX

