# Sentry Production Setup - Quick Reference

**Purpose:** Quick copy & paste instructions for production Sentry setup.

---

## Step 1: Get Your Sentry DSN

1. Go to https://sentry.io and login
2. Create a new Laravel project (or use existing)
3. Copy your DSN (looks like: `https://xxx@xxx.ingest.sentry.io/xxx`)

---

## Step 2: Add to Production .env File

Copy and paste these lines into your production `.env` file:

```env
# Sentry Configuration
SENTRY_LARAVEL_DSN=https://your-dsn-here@sentry.io/project-id
SENTRY_ENVIRONMENT=production
SENTRY_RELEASE=
SENTRY_SAMPLE_RATE=1.0
SENTRY_TRACES_SAMPLE_RATE=0.1
SENTRY_PROFILES_SAMPLE_RATE=0.1
SENTRY_SEND_DEFAULT_PII=false

# Breadcrumbs
SENTRY_BREADCRUMBS_LOGS_ENABLED=true
SENTRY_BREADCRUMBS_CACHE_ENABLED=true
SENTRY_BREADCRUMBS_SQL_QUERIES_ENABLED=true
SENTRY_BREADCRUMBS_SQL_BINDINGS_ENABLED=false
SENTRY_BREADCRUMBS_QUEUE_INFO_ENABLED=true
SENTRY_BREADCRUMBS_HTTP_CLIENT_REQUESTS_ENABLED=true

# Performance Tracing
SENTRY_TRACE_QUEUE_ENABLED=true
SENTRY_TRACE_SQL_QUERIES_ENABLED=true
SENTRY_TRACE_SQL_BINDINGS_ENABLED=false
SENTRY_TRACE_VIEWS_ENABLED=true
SENTRY_TRACE_LIVEWIRE_ENABLED=true
SENTRY_TRACE_HTTP_CLIENT_REQUESTS_ENABLED=true
SENTRY_TRACE_CACHE_ENABLED=true
```

⚠️ **IMPORTANT:** Replace `https://your-dsn-here@sentry.io/project-id` with your actual DSN from Step 1!

---

## Step 3: Apply Changes

Run these commands on your production server:

```bash
# Clear config cache
php artisan config:clear

# Restart PHP-FPM (if using)
sudo systemctl restart php8.4-fpm
# OR
sudo service php8.4-fpm restart

# Restart queue workers (if using)
php artisan queue:restart

# Restart Horizon (if using)
php artisan horizon:terminate
```

---

## Step 4: Verify It's Working

1. Check your Sentry dashboard at https://sentry.io
2. Any new errors should appear within seconds
3. Test by triggering an error (if safe to do so)

---

## Step 5: Set Up Alerts (Recommended)

1. In Sentry dashboard: Settings → Projects → Your Project
2. Click "Alerts" → "Create Alert Rule"
3. Configure:
   - Alert Name: "New Errors"
   - Conditions: "An issue is created"
   - Actions: "Send a notification via Email"
   - Recipients: Your email address
4. Click "Save Rule"

---

## Optional: Release Tracking

To track which deployment caused errors, set `SENTRY_RELEASE`:

**Option 1: Manual version**
```env
SENTRY_RELEASE=v1.2.3
```

**Option 2: Git commit hash (automatic)**
```env
SENTRY_RELEASE=$(git rev-parse --short HEAD)
```

**Option 3: Add to deployment script**
```bash
export SENTRY_RELEASE=$(git rev-parse --short HEAD)
php artisan config:clear
```

---

## Troubleshooting

If Sentry isn't working:

1. **Check DSN is correct:**
   ```bash
   php artisan tinker
   config('sentry.dsn')  # Should show your DSN
   ```

2. **Check Sentry client:**
   ```php
   \Sentry\SentrySdk::getCurrentHub()->getClient();
   # Should return client instance (not null)
   ```

3. **Test manually:**
   ```php
   \Sentry\captureMessage('Test message');
   # Check Sentry dashboard - should see the message
   ```

4. **Check logs:**
   ```bash
   tail -f storage/logs/laravel.log
   # Look for Sentry-related errors
   ```

---

## Quick Reference

- **Sentry Dashboard:** https://sentry.io
- **Documentation:** https://docs.sentry.io/platforms/php/guides/laravel/
- **Full Setup Guide:** See `docs/sentry/SETUP.md`

---

**Last Updated:** 2025-01-XX

