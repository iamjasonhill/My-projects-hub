# PHPStan Baseline Tracking

**Purpose:** Track baseline error reduction over time as we streamline code across projects.

**Goal:** Gradually reduce baseline errors by fixing issues when touching files.

---

## How to Use

### 1. Check Current Baseline Size
```bash
# Moveroo-Cars-2026
cd Moveroo-Cars-2026 && grep -c "message:" phpstan-baseline.neon

# Moveroo Removals 2026
cd "Moveroo Removals 2026" && grep -c "message:" phpstan-baseline.neon
```

### 2. After Fixing Errors, Regenerate Baseline
```bash
# In each project directory
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app
```

### 3. Update This File
Add a new entry with the date and error count.

---

## Moveroo-Cars-2026

| Date | Error Count | Change | Notes |
|------|-------------|--------|-------|
| 2025-01-03 | 1,002 | - | Initial baseline established |
| | | | |

**Goal:** Reduce to < 500 errors over 6 months

**Top Error Types:**
- `property.notFound` (351) - Missing properties
- `return.type` (111) - Missing return types
- `argument.type` (69) - Missing type hints

**Files with Most Errors:**
- `BookingController.php` (41 errors)
- `QuoteProcessingService.php` (32 errors)

---

## Moveroo Removals 2026

| Date | Error Count | Change | Notes |
|------|-------------|--------|-------|
| 2025-01-03 | 795 | - | Initial baseline established |
| | | | |

**Goal:** Reduce to < 400 errors over 6 months

**Top Error Types:**
- `property.notFound` (388) - Missing properties
- `property.phpDocType` (53) - Missing PHPDoc types
- `method.notFound` (43) - Missing methods

---

## Strategy

### Primary Approach: Fix When Touching Files
- ✅ Fix baseline errors in files you're already editing
- ✅ Fix new errors immediately (don't add to baseline)
- ✅ Regenerate baseline monthly to remove fixed issues

### Secondary: Periodic Cleanup
- Set aside time (1-2 hours/month) to fix errors in specific areas
- Focus on files with many errors (e.g., BookingController.php)

### Tracking Progress
- Monthly baseline regeneration
- Update this file after each regeneration
- Monitor trend: Are we reducing errors over time?

---

## Quick Commands

### Check Baseline Size
```bash
# Quick check script
cd /Users/jasonhill/Projects/laravel-projects
echo "Moveroo-Cars-2026: $(cd Moveroo-Cars-2026 && grep -c 'message:' phpstan-baseline.neon) errors"
echo "Moveroo Removals 2026: $(cd 'Moveroo Removals 2026' && grep -c 'message:' phpstan-baseline.neon) errors"
```

### Regenerate Baseline (After Fixing Errors)
```bash
# In project directory
./vendor/bin/phpstan analyse --memory-limit=2G --generate-baseline phpstan-baseline.neon app
```

### View Baseline Error Types
```bash
# In project directory
grep "identifier:" phpstan-baseline.neon | sort | uniq -c | sort -rn | head -10
```

---

## Notes

- **Baseline Purpose:** Captures existing errors so PHPStan only shows NEW errors
- **Best Practice:** Fix errors when you touch files, don't fix everything at once
- **Progress Goal:** 50-100 errors reduced per month (natural as you work on files)

