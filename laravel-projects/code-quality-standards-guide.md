# Code Quality Standards Guide

**Purpose:** This document outlines the standard code quality improvements to apply to all Laravel projects. This guide is based on the successful implementation in Moveroo-Cars-2026.

**Reference:** See `Moveroo-Cars-2026/docs/code-quality-improvements-plan.md` for the detailed implementation example.

---

## Overview

This guide covers implementing consistent code quality standards across all projects:

1. **Laravel Pint** - Code formatting (PSR-12)
2. **PHPStan + Larastan** - Static analysis
3. **Pre-commit hooks** - Automated checks
4. **Codacy compliance** - Code quality checks (optional)

---

## Phase 1: Laravel Pint (Code Formatting)

### Installation

```bash
composer require --dev laravel/pint
```

### Initial Setup

```bash
# Run Pint on entire codebase to fix all style issues
./vendor/bin/pint

# Check what would be fixed without making changes
./vendor/bin/pint --test
```

### Configuration

Create `pint.json` in project root (optional - uses Laravel defaults):

```json
{
    "preset": "laravel",
    "rules": {
        "simplified_null_return": true,
        "braces": {
            "position_after_control_structures": "same"
        }
    }
}
```

---

## Phase 2: PHPStan + Larastan (Static Analysis)

### Installation

```bash
composer require --dev phpstan/phpstan larastan/larastan
```

### Configuration

Create `phpstan.neon` in project root:

```neon
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app
        - config
        - database/factories
        - database/seeders
    
    # Start with level 5 (moderate strictness)
    level: 5
    
    ignoreErrors:
        - '#PHPDoc tag @var#'
    
    excludePaths:
        - ./*/*/FileToIgnore.php

    checkMissingIterableValueType: false
```

### Generate Baseline

For existing projects with many errors, generate a baseline:

```bash
# Generate baseline (captures existing errors)
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app

# Include baseline in phpstan.neon
# Add this line to phpstan.neon:
# includes:
#     - phpstan-baseline.neon
```

### Usage

```bash
# Check all code
./vendor/bin/phpstan analyse --memory-limit=2G

# Check specific file
./vendor/bin/phpstan analyse --memory-limit=2G app/Http/Controllers/UserController.php

# Update baseline (after fixing issues)
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app
```

---

## Phase 3: Pre-Commit Hook Setup

### Create Pre-Commit Hook

Create `.git/hooks/pre-commit` (make executable):

```bash
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Running pre-commit checks..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get staged PHP files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(php|blade\.php)$')

if [ -z "$STAGED_FILES" ]; then
    echo "No PHP files staged, skipping checks."
    exit 0
fi

# 1. Laravel Pint Code Style Check (Auto-fix)
echo ""
echo "1. Checking and fixing code style with Pint..."
PINT_FIXED=0
for FILE in $STAGED_FILES; do
    if [ -f "$FILE" ]; then
        ./vendor/bin/pint --test "$FILE" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "  🔧 Fixing $FILE..."
            ./vendor/bin/pint "$FILE"
            git add "$FILE"
            PINT_FIXED=1
        fi
    fi
done

if [ $PINT_FIXED -eq 1 ]; then
    echo "  ✅ Code style issues auto-fixed"
    echo "  Re-staging fixed files..."
else
    echo "  ✅ All files already formatted"
fi

# 2. PHP Syntax Check
echo ""
echo "2. Validating PHP syntax..."
SYNTAX_ERRORS=0
for FILE in $STAGED_FILES; do
    if [ -f "$FILE" ] && [[ "$FILE" == *.php ]]; then
        php -l "$FILE" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "  ${RED}❌ Syntax error in $FILE${NC}"
            php -l "$FILE"
            SYNTAX_ERRORS=1
        fi
    fi
done

if [ $SYNTAX_ERRORS -eq 1 ]; then
    echo ""
    echo "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${RED}Pre-commit hook failed: PHP syntax errors found${NC}"
    echo "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi

echo "  ✅ All PHP files have valid syntax"

# 3. PHPStan Static Analysis (on staged files only)
echo ""
echo "3. Running PHPStan static analysis..."
if [ -f "./vendor/bin/phpstan" ]; then
    ./vendor/bin/phpstan analyse --memory-limit=2G --error-format=table $STAGED_FILES 2>&1 | head -50
    PHPSTAN_EXIT=$?
    
    if [ $PHPSTAN_EXIT -ne 0 ]; then
        echo ""
        echo "${YELLOW}⚠️  PHPStan found issues (check output above)${NC}"
        echo "${YELLOW}Note: This won't block the commit, but please review the issues${NC}"
        # Uncomment to make PHPStan block commits:
        # exit 1
    else
        echo "  ✅ PHPStan checks passed"
    fi
else
    echo "  ⚠️  PHPStan not installed (optional)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${GREEN}✅ Pre-commit checks passed${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Test Pre-Commit Hook

```bash
# Test manually
.git/hooks/pre-commit

# Or make a test commit
git add .
git commit -m "Test pre-commit hook"
```

---

## Phase 4: Optional Enhancements

### Codacy Compliance (Project-Specific)

If your project uses Codacy, create custom artisan commands to check compliance:

```bash
# Example artisan command structure
php artisan make:command CheckCodacyCompliance
```

### IDE Helper (Optional)

```bash
composer require --dev barryvdh/laravel-ide-helper
php artisan ide-helper:generate
php artisan ide-helper:models --nowrite
```

### Rector (Automated Refactoring)

```bash
composer require --dev rector/rector
```

---

## Recommended Implementation Order

### For New Projects
1. ✅ Install Pint → Run on entire codebase
2. ✅ Install PHPStan + Larastan → Configure level 5
3. ✅ Set up pre-commit hook
4. ✅ Gradually increase PHPStan level (5 → 6 → 7 → 8)

### For Existing Projects
1. ✅ Install Pint → Run on entire codebase → Commit formatting separately
2. ✅ Install PHPStan + Larastan → Configure level 5
3. ✅ **Generate baseline** (important for existing codebases)
4. ✅ Set up pre-commit hook
5. ✅ Fix baseline issues incrementally over time

---

## Best Practices

### PHPStan Levels
- **Level 5**: Start here for existing projects (moderate strictness)
- **Level 6-7**: Increase after fixing baseline issues
- **Level 8**: Maximum strictness (aim for this over time)

### Baselines
- Always generate baselines for existing projects
- Don't try to fix everything at once
- Fix issues when you touch files
- Remove fixed issues from baseline gradually

### Pre-Commit Performance
- Only check staged files (not entire codebase)
- Run fast checks first (syntax, Pint)
- Run slow checks last (PHPStan)
- Target: < 10 seconds for typical commit

---

## Commands Quick Reference

### Pint
```bash
./vendor/bin/pint              # Auto-fix all files
./vendor/bin/pint --test        # Check without fixing
./vendor/bin/pint app/Models    # Fix specific directory
```

### PHPStan
```bash
./vendor/bin/phpstan analyse --memory-limit=2G                    # Check all
./vendor/bin/phpstan analyse --memory-limit=2G app/Http/Controllers # Check directory
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app  # Generate baseline
```

### Pre-Commit
```bash
.git/hooks/pre-commit  # Test manually
git commit -m "..."    # Runs automatically
```

---

## Project Status Tracking

When implementing in a project, track your progress:

- [ ] Pint installed and configured
- [ ] Pint run on entire codebase
- [ ] PHPStan + Larastan installed
- [ ] PHPStan configured (level ___)
- [ ] Baseline generated (if existing project)
- [ ] Pre-commit hook created and tested
- [ ] All checks passing

---

## Notes

- This guide is based on Laravel projects, but concepts can apply to other PHP projects
- Adjust PHPStan paths based on your project structure
- Pre-commit hook can be customized per project needs
- Consider CI/CD integration for full analysis on all branches

---

**Last Updated:** 2025-11-04  
**Reference Implementation:** `Moveroo-Cars-2026/docs/code-quality-improvements-plan.md`

