# Sentry Setup Guide

**Purpose:** Complete setup guide for Sentry error tracking and performance monitoring in Laravel projects.

---

## Overview

Sentry provides:
- **Error Tracking**: Real-time exception monitoring
- **Performance Monitoring**: APM (Application Performance Monitoring)
- **Release Tracking**: Track errors by deployment version
- **User Context**: See which users are affected
- **Breadcrumbs**: Detailed context leading to errors
- **Alerts**: Email, Slack, PagerDuty notifications

**Complements Telescope:**
- **Telescope**: Local debugging and development monitoring
- **Sentry**: Production error tracking and alerting

---

## Step 1: Create Sentry Account & Project

### 1.1 Sign Up / Login
1. Go to https://sentry.io
2. Sign up for free account (or login if you have one)
3. Free tier includes: 5,000 errors/month, 1 project

### 1.2 Create Laravel Project
1. In Sentry dashboard, click **"Create Project"**
2. Select **"Laravel"** as the platform
3. Enter project name (e.g., `Your-Project-Name`)
4. Click **"Create Project"**

### 1.3 Get Your DSN
After creating the project, you'll see your **DSN** (Data Source Name):
```
https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@o1234567.ingest.sentry.io/1234567
```

**Copy this DSN** - you'll need it for configuration.

---

## Step 2: Local Development Setup

### 2.1 Add Environment Variables

Add these to your **local `.env` file**:

```env
# Sentry Configuration
SENTRY_LARAVEL_DSN=https://your-dsn-here@sentry.io/project-id
SENTRY_ENVIRONMENT=local
SENTRY_RELEASE=
SENTRY_SAMPLE_RATE=1.0
SENTRY_TRACES_SAMPLE_RATE=0.1
SENTRY_PROFILES_SAMPLE_RATE=0.1
SENTRY_SEND_DEFAULT_PII=false

# Breadcrumbs (optional - defaults are good)
SENTRY_BREADCRUMBS_LOGS_ENABLED=true
SENTRY_BREADCRUMBS_CACHE_ENABLED=true
SENTRY_BREADCRUMBS_SQL_QUERIES_ENABLED=true
SENTRY_BREADCRUMBS_SQL_BINDINGS_ENABLED=false
SENTRY_BREADCRUMBS_QUEUE_INFO_ENABLED=true
SENTRY_BREADCRUMBS_HTTP_CLIENT_REQUESTS_ENABLED=true

# Performance Tracing (optional)
SENTRY_TRACE_QUEUE_ENABLED=true
SENTRY_TRACE_SQL_QUERIES_ENABLED=true
SENTRY_TRACE_SQL_BINDINGS_ENABLED=false
SENTRY_TRACE_VIEWS_ENABLED=true
SENTRY_TRACE_LIVEWIRE_ENABLED=true
SENTRY_TRACE_HTTP_CLIENT_REQUESTS_ENABLED=true
SENTRY_TRACE_CACHE_ENABLED=true
```

**Replace `https://your-dsn-here@sentry.io/project-id`** with your actual DSN from Step 1.3.

### 2.2 Test Sentry Integration

Create a test route to verify Sentry is working:

```php
// routes/web.php (temporary test route)
Route::get('/test-sentry', function () {
    throw new \Exception('Sentry test error - ' . now());
})->middleware('auth'); // Protect this route
```

1. Visit: `http://localhost:8000/test-sentry`
2. Check your Sentry dashboard - you should see the error appear within seconds
3. **Remove the test route** after confirming it works

### 2.3 Verify Configuration

Check that Sentry is properly configured:

```bash
php artisan tinker
```

```php
// In Tinker
\Sentry\SentrySdk::getCurrentHub()->getClient();
// Should return Sentry client instance (not null)

// Test sending an event
\Sentry\captureMessage('Test message from Tinker');
// Check Sentry dashboard - should see the message
```

---

## Step 3: Production Setup

### 3.1 Production Environment Variables

**Copy and paste these into your production `.env` file:**

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

**Important:**
- Replace `https://your-dsn-here@sentry.io/project-id` with your actual DSN
- Set `SENTRY_ENVIRONMENT=production` (not `local`)
- Use the **same DSN** for both local and production (or create separate projects)

### 3.2 Production Deployment Steps

**After adding environment variables to production:**

1. **Clear config cache:**
   ```bash
   php artisan config:clear
   ```

2. **Restart application:**
   ```bash
   # If using PHP-FPM
   sudo systemctl restart php8.4-fpm
   
   # If using queue workers
   php artisan queue:restart
   
   # If using Horizon
   php artisan horizon:terminate
   ```

3. **Verify Sentry is working:**
   - Check Sentry dashboard for any errors
   - Monitor for a few minutes to see if errors start appearing

### 3.3 Release Tracking (Optional but Recommended)

Track which deployment caused errors by setting the release:

**Option A: Manual Release (Simple)**
```env
SENTRY_RELEASE=v1.2.3
```

**Option B: Git Commit Hash (Automatic)**
```env
SENTRY_RELEASE=$(git rev-parse --short HEAD)
```

**Option C: In Code (Most Flexible)**
Update `config/sentry.php`:
```php
'release' => env('SENTRY_RELEASE', trim(exec('git --git-dir ' . base_path('.git') . ' log --pretty="%h" -n1 HEAD'))),
```

This automatically uses the current git commit hash as the release version.

---

## Step 4: Configure Alerts

### 4.1 Set Up Email Alerts

1. In Sentry dashboard, go to **Settings** → **Projects** → **Your Project**
2. Click **"Alerts"** → **"Create Alert Rule"**
3. Configure:
   - **Alert Name**: "New Errors"
   - **Conditions**: "An issue is created"
   - **Actions**: "Send a notification via Email"
   - **Recipients**: Your email address
4. Click **"Save Rule"**

### 4.2 Set Up Slack Alerts (Optional)

1. In Sentry dashboard, go to **Settings** → **Integrations**
2. Click **"Slack"** → **"Add Integration"**
3. Follow the setup wizard
4. Create alert rules to send to Slack channels

### 4.3 Recommended Alert Rules

**Critical Errors (Immediate):**
- Alert when: Issue frequency > 10 in 1 minute
- Action: Email + Slack notification

**New Error Types:**
- Alert when: New issue is created
- Action: Email notification

**Performance Issues:**
- Alert when: Transaction duration > 2 seconds
- Action: Email notification

---

## Step 5: Ignore Specific Errors

Some errors you might want to ignore (e.g., bot scans, expected 404s):

### 5.1 Ignore in Config

Update `config/sentry.php`:

```php
'ignore_exceptions' => [
    \Symfony\Component\HttpKernel\Exception\NotFoundHttpException::class,
    \Illuminate\Auth\AuthenticationException::class,
    // Add other exceptions to ignore
],
```

### 5.2 Ignore in Code

```php
use Sentry\State\Scope;

\Sentry\configureScope(function (Scope $scope): void {
    $scope->setTag('ignore', 'true');
});
```

---

## Step 6: User Context

Sentry automatically captures user information when authenticated. To add custom context:

### 6.1 Add User Context

```php
use Sentry\State\Scope;

if (auth()->check()) {
    \Sentry\configureScope(function (Scope $scope): void {
        $scope->setUser([
            'id' => auth()->id(),
            'email' => auth()->user()->email,
            'username' => auth()->user()->name,
        ]);
    });
}
```

### 6.2 Add Custom Tags

```php
\Sentry\configureScope(function (Scope $scope): void {
    $scope->setTag('environment', app()->environment());
    $scope->setTag('feature', 'quote-submission');
});
```

---

## Configuration Reference

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SENTRY_LARAVEL_DSN` | `null` | Your Sentry DSN (required) |
| `SENTRY_ENVIRONMENT` | `APP_ENV` | Environment name (local, staging, production) |
| `SENTRY_RELEASE` | `null` | Release version (git hash, version number) |
| `SENTRY_SAMPLE_RATE` | `1.0` | Error sampling rate (0.0 to 1.0) |
| `SENTRY_TRACES_SAMPLE_RATE` | `null` | Performance trace sampling (0.0 to 1.0) |
| `SENTRY_PROFILES_SAMPLE_RATE` | `null` | Profile sampling (0.0 to 1.0) |
| `SENTRY_SEND_DEFAULT_PII` | `false` | Send personally identifiable information |

### Recommended Settings

**Local Development:**
- `SENTRY_SAMPLE_RATE=1.0` (capture all errors)
- `SENTRY_TRACES_SAMPLE_RATE=0.1` (10% performance traces)

**Production:**
- `SENTRY_SAMPLE_RATE=1.0` (capture all errors)
- `SENTRY_TRACES_SAMPLE_RATE=0.1` (10% performance traces to avoid overhead)
- `SENTRY_SEND_DEFAULT_PII=false` (privacy compliance)

---

## Testing

### Test Error Reporting

```php
// In a controller or route
Route::get('/test-sentry', function () {
    throw new \Exception('Sentry test error - ' . now());
})->middleware('auth');
```

### Test Performance Monitoring

```php
// In a controller
Route::get('/test-sentry-performance', function () {
    \Sentry\startTransaction(['name' => 'test-transaction']);
    
    // Simulate some work
    sleep(1);
    
    \Sentry\finishTransaction();
    
    return 'Performance test complete';
})->middleware('auth');
```

---

## Troubleshooting

### Sentry Not Capturing Errors

1. **Check DSN is set:**
   ```bash
   php artisan tinker
   config('sentry.dsn')  # Should return your DSN
   ```

2. **Check Sentry client:**
   ```php
   \Sentry\SentrySdk::getCurrentHub()->getClient();
   // Should return client instance
   ```

3. **Check logs:**
   ```bash
   tail -f storage/logs/laravel.log
   # Look for Sentry-related errors
   ```

4. **Test manually:**
   ```php
   \Sentry\captureMessage('Test message');
   ```

### Performance Monitoring Not Working

1. **Check traces sample rate:**
   ```bash
   config('sentry.traces_sample_rate')  # Should be > 0
   ```

2. **Verify tracing is enabled:**
   ```php
   config('sentry.tracing.queue_job_transactions')  # Should be true
   ```

### Too Many Events

If you're hitting rate limits:
- Reduce `SENTRY_SAMPLE_RATE` to `0.5` (50% sampling)
- Add more exceptions to `ignore_exceptions`
- Filter out bot traffic

---

## Best Practices

1. **Use Release Tracking**: Set `SENTRY_RELEASE` to track which deployment caused errors
2. **Set Up Alerts**: Configure email/Slack alerts for critical errors
3. **Ignore Expected Errors**: Add 404s, authentication errors to ignore list
4. **Monitor Performance**: Use traces to identify slow queries/endpoints
5. **Review Regularly**: Check Sentry dashboard weekly for new error patterns
6. **Tag Appropriately**: Add tags to group errors by feature, environment, etc.

---

## Integration with Telescope

Sentry and Telescope work together:

- **Telescope**: Use for local development debugging
- **Sentry**: Use for production error tracking

When an error occurs in production:
1. Sentry captures the error and sends alert
2. Use Telescope locally to debug the same issue
3. Telescope provides detailed query/request context
4. Sentry provides user context and breadcrumbs

---

## Security Notes

1. **DSN is Public**: The DSN can be exposed in frontend code - this is safe
2. **PII Settings**: Keep `SENTRY_SEND_DEFAULT_PII=false` unless needed
3. **SQL Bindings**: Keep `SENTRY_BREADCRUMBS_SQL_BINDINGS_ENABLED=false` to avoid logging sensitive data
4. **Access Control**: Sentry dashboard access is controlled by Sentry account permissions

---

## Next Steps

1. ✅ Set up Sentry account and get DSN
2. ✅ Add environment variables to local `.env`
3. ✅ Test error reporting locally
4. ✅ Add environment variables to production `.env`
5. ✅ Configure alerts (email/Slack)
6. ✅ Set up release tracking
7. ✅ Monitor Sentry dashboard for errors

---

## Support

- **Sentry Docs**: https://docs.sentry.io/platforms/php/guides/laravel/
- **Laravel Sentry Package**: https://github.com/getsentry/sentry-laravel
- **Sentry Dashboard**: https://sentry.io

---

**Last Updated:** 2025-01-XX

