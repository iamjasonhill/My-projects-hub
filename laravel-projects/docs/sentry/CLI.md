# Sentry CLI & Error Checking

**Purpose:** Set up Sentry CLI and Laravel artisan command to periodically check errors.

---

## Option 1: Laravel Artisan Command (Recommended)

### Setup

1. **Get Sentry Auth Token:**
   - Go to https://sentry.io/settings/account/api/auth-tokens/
   - Click "Create New Token"
   - Give it a name: "Laravel CLI"
   - Select scopes: `org:read`, `project:read`, `event:read`
   - Copy the token

2. **Add to `.env`:**
   ```env
   SENTRY_AUTH_TOKEN=your-auth-token-here
   SENTRY_ORG=your-org-slug
   SENTRY_PROJECT=your-project-slug
   ```

   **To find your org and project slugs:**
   - Org slug: Check URL when logged into Sentry (e.g., `https://sentry.io/organizations/your-org-slug/`)
   - Project slug: Check project settings or URL (e.g., `https://sentry.io/organizations/your-org-slug/projects/your-project-slug/`)

3. **Test the command:**
   ```bash
   php artisan sentry:check-errors
   ```

### Usage

```bash
# Check last 10 errors
php artisan sentry:check-errors

# Check last 20 errors
php artisan sentry:check-errors --limit=20

# Only unresolved issues
php artisan sentry:check-errors --unresolved

# Show statistics
php artisan sentry:check-errors --stats

# JSON output
php artisan sentry:check-errors --format=json

# Summary format
php artisan sentry:check-errors --format=summary
```

### Schedule Periodic Checks

Add to `app/Console/Kernel.php`:

```php
// Check Sentry errors every hour
$schedule->command('sentry:check-errors --limit=20 --stats')
    ->hourly()
    ->appendOutputTo(storage_path('logs/sentry-checks.log'));

// Daily summary
$schedule->command('sentry:check-errors --limit=50 --stats --format=summary')
    ->dailyAt('09:00')
    ->appendOutputTo(storage_path('logs/sentry-daily-summary.log'));
```

---

## Option 2: Sentry CLI (Alternative)

### Installation

**macOS:**
```bash
brew install getsentry/tools/sentry-cli
```

**Linux:**
```bash
# Download and install
curl -sL https://sentry.io/get-cli/ | sh
```

**Windows:**
```powershell
scoop install sentry-cli
```

### Authentication

```bash
sentry-cli login
```

This will open your browser to authenticate. Alternatively, set the token:

```bash
export SENTRY_AUTH_TOKEN=your-token-here
export SENTRY_ORG=your-org-slug
export SENTRY_PROJECT=your-project-slug
```

### Usage

```bash
# List issues
sentry-cli issues list

# List unresolved issues
sentry-cli issues list --status=unresolved

# Get issue details
sentry-cli issues show ISSUE_ID

# List events for an issue
sentry-cli events list --issue=ISSUE_ID
```

### Schedule with Cron

Add to crontab (`crontab -e`):

```bash
# Check Sentry errors every hour
0 * * * * cd /path/to/project && sentry-cli issues list --limit=20 >> /path/to/logs/sentry-checks.log 2>&1
```

---

## Option 3: npx Sentry CLI (Quick Access)

### Quick Commands

```bash
# List recent errors
npx -y @sentry/cli issues list \
  --auth-token "$SENTRY_ACCESS_TOKEN" \
  --org "$SENTRY_ORG" \
  --project "$SENTRY_PROJECT" \
  --status unresolved \
  --max-rows 10

# List only error-level issues
npx -y @sentry/cli issues list \
  --auth-token "$SENTRY_ACCESS_TOKEN" \
  --org "$SENTRY_ORG" \
  --project "$SENTRY_PROJECT" \
  --query "level:error is:unresolved" \
  --max-rows 20

# List errors from production environment
npx -y @sentry/cli issues list \
  --auth-token "$SENTRY_ACCESS_TOKEN" \
  --org "$SENTRY_ORG" \
  --project "$SENTRY_PROJECT" \
  --query "environment:production level:error" \
  --max-rows 15
```

### Environment Variables

Set these for your project (or use inline in commands):

```bash
export SENTRY_ACCESS_TOKEN="your_token_here"
export SENTRY_ORG="your-org-slug"
export SENTRY_PROJECT="your-project-slug"
```

### Common Query Patterns

```bash
# Production errors from last 7 days
--query "environment:production level:error firstSeen:>-7d"

# Unresolved errors with specific text in title
--query "is:unresolved \"foreign key\""

# Errors excluding warnings
--query "level:error level:fatal"

# High-frequency errors (most events)
--query "is:unresolved" --pages 5
```

### Filter by Status

```bash
# Only unresolved errors
--status unresolved

# Only resolved errors
--status resolved

# All errors (including muted)
--all
```

### Filter by Level

```bash
# Error level only
--query "level:error"

# Warning level only
--query "level:warning"

# Fatal level only
--query "level:fatal"
```

### Filter by Environment

```bash
# Production only
--query "environment:production"

# Staging only
--query "environment:staging"

# Local only
--query "environment:local"
```

---

## Recommended Setup

**For most use cases, use Option 1 (Laravel Artisan Command):**

1. ✅ No external dependencies (uses HTTP client)
2. ✅ Integrated with Laravel
3. ✅ Easy to schedule
4. ✅ Can be extended with custom logic
5. ✅ Works in all environments

**Use Option 2 (Sentry CLI) if:**
- You need advanced Sentry CLI features
- You want to manage releases/deployments
- You need to upload source maps

**Use Option 3 (npx) if:**
- You need quick one-off checks
- You don't want to install CLI globally
- You're using it from different machines

---

## Troubleshooting

### "SENTRY_AUTH_TOKEN is not configured"
- Get token from: https://sentry.io/settings/account/api/auth-tokens/
- Add to `.env` file
- Run `php artisan config:clear`

### "Invalid Sentry DSN format"
- Check your DSN in `.env`
- Should be: `https://key@o1234567.ingest.sentry.io/1234567`

### "Failed to fetch issues from Sentry API"
- Check your `SENTRY_ORG` and `SENTRY_PROJECT` are correct
- Verify auth token has correct permissions
- Check network connectivity

### "404 Not Found"
- Verify `SENTRY_ORG` and `SENTRY_PROJECT` slugs are correct
- Check project exists in your Sentry organization

### Command hangs or times out
- Add `--max-rows` to limit results
- Use `--pages 1` to limit pages fetched

---

## Security Note

⚠️ **Never commit Sentry tokens to git!**

- Add tokens to `.env` or environment variables
- Use `.gitignore` to exclude files with tokens
- Rotate tokens if accidentally exposed

---

## Next Steps

1. ✅ Get Sentry auth token
2. ✅ Add to `.env` file
3. ✅ Test command: `php artisan sentry:check-errors`
4. ✅ Schedule periodic checks in `Kernel.php`
5. ✅ Monitor logs for error trends

---

## Resources

- [Sentry CLI Documentation](https://docs.sentry.io/product/cli/)
- [Sentry Query Syntax](https://docs.sentry.io/product/issues/search/)
- [Sentry API Documentation](https://docs.sentry.io/api/)

---

**Last Updated:** 2025-01-XX

