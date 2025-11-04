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

## Prerequisites & Version Requirements

Before starting, ensure your environment meets these requirements:

### Required Versions
- **PHP**: 8.2 or higher (8.3+ recommended)
- **Laravel**: 10.x or 11.x (Laravel 12+ also supported)
- **Composer**: 2.x
- **Git**: 2.x

### System Requirements
- **Operating System**: macOS, Linux, or Windows (WSL recommended for Windows)
- **Memory**: Minimum 2GB RAM (4GB+ recommended for large projects)
- **Disk Space**: ~500MB for dependencies

### Verify Your Setup

```bash
# Check PHP version
php -v  # Should be 8.2+

# Check Laravel version
php artisan --version

# Check Composer version
composer --version

# Check Git version
git --version
```

### Compatibility Notes
- **PHP 8.1**: May work but not recommended; some features require PHP 8.2+
- **Laravel 9.x**: Should work, but Laravel 10+ is recommended
- **Windows**: Use WSL2 for best compatibility with bash scripts (pre-commit hooks)

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
    # Include baseline after generating it:
    # - phpstan-baseline.neon

parameters:
    paths:
        - app
        - config
        - database/factories
        - database/seeders
    
    # Start with level 5 (moderate strictness)
    level: 5
    
    # Cache directory for performance
    tmpDir: storage/phpstan
    
    # Ignore errors from third-party code
    excludePaths:
        - vendor/
        - bootstrap/cache/
        - storage/
        - public/
    
    ignoreErrors:
        - '#PHPDoc tag @var#'
    
    checkMissingIterableValueType: false
```

### Generate Baseline

For existing projects with many errors, generate a baseline:

```bash
# Generate baseline (captures existing errors)
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app

# Include baseline in phpstan.neon
# Add this line to phpstan.neon includes section:
# - phpstan-baseline.neon
```

### Baseline Management

Baselines allow you to gradually improve code quality without blocking development.

**Initial Baseline Generation:**
```bash
# Generate baseline for entire codebase
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app
```

**Updating Baseline Incrementally:**
1. Fix issues in specific files/directories
2. Remove fixed issues from baseline:
   ```bash
   # Re-run analysis - it will show fewer errors
   ./vendor/bin/phpstan analyse --memory-limit=2G
   
   # Regenerate baseline to remove fixed issues
   ./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app
   ```

**Baseline Best Practices:**
- ✅ Fix issues when you touch files (don't fix unrelated code)
- ✅ Remove fixed issues from baseline regularly
- ✅ Track baseline size reduction over time
- ✅ Don't add new issues to baseline (fix them immediately)
- ✅ Review baseline file occasionally to see what's left

**Tracking Progress:**
```bash
# Count issues in baseline (approximate)
grep -c "message:" phpstan-baseline.neon

# Or check baseline file size
ls -lh phpstan-baseline.neon
```

**When to Regenerate Baseline:**
- After fixing a batch of issues
- When baseline file becomes too large
- When you've fixed all issues in a specific directory
- Monthly cleanup sessions

### Usage

```bash
# Check all code
./vendor/bin/phpstan analyse --memory-limit=2G

# Check specific file
./vendor/bin/phpstan analyse --memory-limit=2G app/Http/Controllers/UserController.php

# Check specific directory
./vendor/bin/phpstan analyse --memory-limit=2G app/Http/Controllers

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

### Codacy Compliance Checker

Codacy compliance checks help catch security issues and code quality problems before they reach production.

**What Codacy Checks For:**
- **Security Issues**: Shell execution functions (`exec()`, `shell_exec()`, `system()`, `passthru()`, `proc_open()`)
- **Type Checking**: `gettype()` usage (should use `is_*` functions instead)
- **Code Quality**: Implicit boolean comparisons, leading `!` operators
- **Best Practices**: Unsafe function usage patterns

**Create Codacy Compliance Command:**

```bash
php artisan make:command CheckCodacyCompliance
```

**Implementation Example:**

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class CheckCodacyCompliance extends Command
{
    protected $signature = 'check:codacy-compliance {path?}';
    protected $description = 'Check PHP files for Codacy compliance issues';

    public function handle()
    {
        $path = $this->argument('path') ?: app_path();
        $issues = [];
        
        // Check for shell execution functions
        $shellFunctions = ['exec', 'shell_exec', 'system', 'passthru', 'proc_open'];
        // Check for gettype() usage
        // Check for implicit boolean comparisons
        // Check for leading ! operators
        
        // Report findings
        if (empty($issues)) {
            $this->info('✅ No Codacy compliance issues found');
            return 0;
        }
        
        foreach ($issues as $issue) {
            $this->error("❌ {$issue['file']}: {$issue['message']}");
        }
        
        return 1;
    }
}
```

**Create Critical Issues Checker:**

```bash
php artisan make:command CheckCodacyCritical
```

This checks only Priority 1 (Critical) issues like security vulnerabilities.

**Usage:**

```bash
# Check all files
php artisan check:codacy-compliance

# Check specific directory
php artisan check:codacy-compliance app/Services

# Check single file
php artisan check:codacy-compliance app/Http/Controllers/UserController.php

# Check only critical issues
php artisan check:codacy-critical
```

**Integration with Pre-Commit:**

Add to your pre-commit hook (see Phase 3):
```bash
# In pre-commit hook, after Pint check:
if php artisan check:codacy-compliance "$FILE" > /dev/null 2>&1; then
    echo "  ✅ $FILE"
else
    echo "  ❌ $FILE - Codacy issues found"
    php artisan check:codacy-compliance "$FILE"
    exit 1
fi
```

### Blade Property Access Checker

Blade property checker ensures PHP 8.4+ compatibility by checking for unsafe property access patterns in Blade templates.

**What It Checks:**
- Unsafe property access on `stdClass` objects (from `DB::table()` queries)
- Missing null coalescing operators on potentially null objects
- **Note**: Eloquent models are safe and don't need null coalescing

**Create Blade Property Checker Command:**

```bash
php artisan make:command CheckBladePropertyAccess
```

**Implementation Example:**

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class CheckBladePropertyAccess extends Command
{
    protected $signature = 'check:blade-properties {--path=resources/views}';
    protected $description = 'Check Blade files for unsafe property access patterns';

    public function handle()
    {
        $path = $this->option('path');
        // Scan Blade files for unsafe patterns
        // Report issues with file and line numbers
        
        return 0;
    }
}
```

**Usage:**

```bash
# Check all Blade files
php artisan check:blade-properties

# Check specific directory
php artisan check:blade-properties --path=resources/views/quotes

# Check specific view
php artisan check:blade-properties --path=resources/views/providers/edit.blade.php
```

**Important Notes:**
- **Eloquent Models**: Files like `$quote->id` are safe (Eloquent models handle nulls)
- **stdClass Objects**: Files like `$result->field` from `DB::table()` need `$result->field ?? ''`
- The checker is directory-based, not file-based (for performance)
- Use manually or in CI/CD, not typically in pre-commit (can be slow)

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

## CI/CD Integration

Integrating code quality checks into your CI/CD pipeline ensures all code meets standards before merging.

### GitHub Actions Example

Create `.github/workflows/code-quality.yml`:

```yaml
name: Code Quality Checks

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main, develop ]

jobs:
  code-quality:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: mbstring, xml, curl, bcmath, json
          coverage: none
      
      - name: Install Dependencies
        run: composer install --prefer-dist --no-progress
      
      - name: Run Pint
        run: ./vendor/bin/pint --test
      
      - name: Run PHPStan
        run: ./vendor/bin/phpstan analyse --memory-limit=2G --error-format=github
        continue-on-error: true
      
      - name: Run Codacy Compliance Check
        run: php artisan check:codacy-compliance
        continue-on-error: true
      
      - name: Run Blade Property Check
        run: php artisan check:blade-properties
        continue-on-error: true
```

### GitLab CI Example

Create `.gitlab-ci.yml` (add to existing file):

```yaml
code-quality:
  stage: test
  image: php:8.3-cli
  before_script:
    - apt-get update -qq && apt-get install -y -qq git unzip
    - curl -sS https://getcomposer.org/installer | php
    - php composer.phar install --prefer-dist --no-progress
  script:
    - ./vendor/bin/pint --test
    - ./vendor/bin/phpstan analyse --memory-limit=2G
    - php artisan check:codacy-compliance
  only:
    - merge_requests
    - main
    - develop
```

### Best Practices for CI/CD

**Performance:**
- Run Pint check first (fastest)
- Run PHPStan with memory limit
- Use `continue-on-error: true` for warnings (not failures)
- Cache Composer dependencies between runs

**Blocking vs Warning:**
- **Block merges**: Pint failures, PHP syntax errors
- **Warn but allow**: PHPStan issues (if using baseline), Codacy non-critical issues

**Configuration:**
```yaml
# Block on critical issues only
- name: Run Codacy Critical Check
  run: php artisan check:codacy-critical
  # No continue-on-error - this should block

# Warn on other issues
- name: Run Codacy Full Check
  run: php artisan check:codacy-compliance
  continue-on-error: true
```

**Full Analysis in CI:**
- Run PHPStan on entire codebase (not just changed files)
- This catches issues that might not be in staged files locally
- Use `--error-format=github` for better GitHub integration

### Environment Variables

```yaml
env:
  PHPSTAN_MEMORY_LIMIT: 2G
  SKIP_PHPSTAN: false  # Set to true to skip in CI
```

---

## Troubleshooting

Common issues and solutions when setting up code quality tools.

### Pint Issues

**Error: "Pint not found"**
```bash
# Solution: Install Pint
composer require --dev laravel/pint

# Verify installation
./vendor/bin/pint --version
```

**Error: "Permission denied"**
```bash
# Solution: Make Pint executable
chmod +x vendor/bin/pint
```

**Pint fixes too many files at once**
```bash
# Run on specific directory first
./vendor/bin/pint app/Http/Controllers

# Or file by file
./vendor/bin/pint app/Http/Controllers/UserController.php
```

### PHPStan Issues

**Error: "Out of memory"**
```bash
# Solution: Increase memory limit
./vendor/bin/phpstan analyse --memory-limit=4G

# Or set in phpstan.neon
parameters:
    memoryLimitFile: 4G
```

**Error: "Too many errors"**
```bash
# Solution: Generate baseline first
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app

# Then include baseline in phpstan.neon
```

**PHPStan is slow**
```bash
# Solution: Use cache directory
# Add to phpstan.neon:
parameters:
    tmpDir: storage/phpstan

# Clear cache if needed
rm -rf storage/phpstan
```

**"Command not found" errors**
```bash
# Solution: Use full path or check vendor/bin
./vendor/bin/phpstan analyse

# Or check if installed
composer show phpstan/phpstan
```

### Pre-Commit Hook Issues

**Hook not running**
```bash
# Solution: Check if file exists and is executable
ls -la .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Test manually
.git/hooks/pre-commit
```

**Hook runs but fails silently**
```bash
# Solution: Add error handling (use set -e in script)
# Check hook output
git commit -m "test" 2>&1 | tee hook-output.txt
```

**"Permission denied" on hook**
```bash
# Solution: Make executable
chmod +x .git/hooks/pre-commit

# Verify permissions
ls -la .git/hooks/pre-commit
# Should show: -rwxr-xr-x
```

**Hook blocks all commits**
```bash
# Temporary bypass (use carefully!)
git commit --no-verify -m "Emergency fix"

# Then fix the hook issue
```

**Hook too slow**
```bash
# Solution: Check only staged files (already done)
# Disable slow checks temporarily by commenting out in hook
# Or increase PHPStan memory limit
```

### Codacy Issues

**"Command not found: check:codacy-compliance"**
```bash
# Solution: Create the artisan command
php artisan make:command CheckCodacyCompliance

# Then implement the command (see Phase 4)
```

**Too many false positives**
```bash
# Solution: Adjust what the command checks
# Or use only critical issues checker
php artisan check:codacy-critical
```

### General Issues

**Composer autoload issues**
```bash
# Solution: Regenerate autoload
composer dump-autoload
```

**Version conflicts**
```bash
# Solution: Check composer.json for version constraints
# Update to compatible versions
composer update phpstan/phpstan larastan/larastan
```

**Windows/WSL issues**
```bash
# Solution: Use WSL2 for bash scripts
# Or convert hook to PowerShell (Windows)
# Or use pre-commit framework (cross-platform)
```

### Getting Help

If you encounter issues not covered here:
1. Check the tool's documentation
2. Review the reference implementation: `Moveroo-Cars-2026/docs/code-quality-improvements-plan.md`
3. Check GitHub issues for the specific tool
4. Verify your PHP/Laravel versions match requirements

---

## Notes

- This guide is based on Laravel projects, but concepts can apply to other PHP projects
- Adjust PHPStan paths based on your project structure
- Pre-commit hook can be customized per project needs
- Consider CI/CD integration for full analysis on all branches

---

**Last Updated:** 2025-11-04  
**Reference Implementation:** `Moveroo-Cars-2026/docs/code-quality-improvements-plan.md`

