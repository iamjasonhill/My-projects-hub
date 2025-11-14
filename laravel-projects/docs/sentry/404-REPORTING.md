# Sentry 404 Error Reporting Setup

**Purpose:** Configure Sentry to report 404 errors while filtering out bot traffic.

---

## Overview

By default, Laravel ignores HTTP exceptions (including 404s) from being reported to Sentry. This guide shows how to enable 404 reporting with smart filtering to avoid noise from bot traffic.

---

## Configuration

### Step 1: Enable 404 Reporting

404 reporting is **disabled by default** to avoid noise. To enable it:

**Add to `.env`:**
```env
SENTRY_REPORT_404=true
```

**Note:** This only works in **production** environment by default. This prevents development 404s from cluttering your Sentry dashboard.

### Step 2: How It Works

The configuration in `bootstrap/app.php`:

1. **Only reports in production** - Prevents dev/test 404s from being reported
2. **Explicit boolean validation** - Uses `filter_var()` to ensure proper boolean conversion
3. **Precise pattern matching** - Uses exact path matches and path-start matching to avoid false positives:
   - WordPress scans: `/wp-admin`, `/wp-login`, `/wp-content`, `/xmlrpc.php`
   - Admin panel scans: `/phpmyadmin`, `/pma`, `/adminer`, `/administrator`
   - File exposure: `/.env`, `/.git`, `/.htaccess`, `/composer.json`, `/package.json`
   - Vulnerability scans: `/.well-known`, `/.git/config`, `/config.php`
4. **Bot user agent filtering** - More specific patterns to avoid false positives:
   - `bot/`, `crawler/`, `spider/`, `scraper/`, `curl/`, `wget/`
   - `python-requests`, `go-http-client`, `java/`, `apache-httpclient`
   - `postman`, `insomnia`, `scrapy/`
5. **Empty user agent handling** - Filters requests with no user agent and no referrer (likely bots)

### Step 3: Customize Filtering

To customize which 404s are reported, edit `bootstrap/app.php`:

```php
$exceptions->report(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e) {
    $path = request()->path();
    $userAgent = request()->userAgent() ?? '';

    // Add your custom filters here
    if (/* your condition */) {
        return false; // Don't report
    }

    return true; // Report to Sentry
});
```

---

## Usage

### Enable 404 Reporting

**Local/Development:**
```env
# In .env
SENTRY_REPORT_404=true
```

**Production:**
```env
# In production .env
SENTRY_REPORT_404=true
```

### Disable 404 Reporting

Simply remove or set to `false`:
```env
SENTRY_REPORT_404=false
```

---

## What Gets Reported

**Reported:**
- ✅ Legitimate user 404s (broken links, typos)
- ✅ Real user navigation errors
- ✅ Missing pages from valid user requests

**Not Reported:**
- ❌ Bot scans (wp-admin, phpmyadmin, etc.)
- ❌ Known bot user agents
- ❌ Development/test environment 404s (unless explicitly enabled)

---

## Filtering Examples

### Example 1: Ignore Specific Paths

```php
$exceptions->report(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e) {
    $path = request()->path();
    
    // Ignore specific paths
    if (in_array($path, ['old-page', 'legacy-url'])) {
        return false;
    }
    
    return true;
});
```

### Example 2: Only Report from Specific Domains

```php
$exceptions->report(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e) {
    $host = request()->getHost();
    
    // Only report from main domain
    if ($host !== 'yourdomain.com') {
        return false;
    }
    
    return true;
});
```

### Example 3: Rate Limiting

```php
use Illuminate\Support\Facades\Cache;

$exceptions->report(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e) {
    $path = request()->path();
    $key = 'sentry_404_' . md5($path);
    
    // Only report same 404 once per hour
    if (Cache::has($key)) {
        return false;
    }
    
    Cache::put($key, true, now()->addHour());
    return true;
});
```

---

## Monitoring 404s in Sentry

Once enabled, 404 errors will appear in Sentry with:

- **URL path** - The requested path
- **User agent** - Browser/client information
- **Referrer** - Where the user came from
- **IP address** - User's IP (if PII enabled)
- **Tags** - Automatically tagged as `NotFoundHttpException`

### Viewing 404s

1. Go to Sentry dashboard
2. Filter by: `exception.type:NotFoundHttpException`
3. Or search: `is:unresolved exception.type:NotFoundHttpException`

---

## Best Practices

1. **Start with filtering enabled** - Use the default bot filters
2. **Monitor for a week** - See what 404s are actually reported
3. **Adjust filters** - Add more patterns if needed
4. **Review regularly** - Check Sentry weekly for new 404 patterns
5. **Fix common 404s** - Use Sentry data to identify broken links

---

## Troubleshooting

### 404s Not Appearing in Sentry

1. **Check configuration:**
   ```bash
   php artisan tinker
   env('SENTRY_REPORT_404')  # Should be 'true' or '1'
   app()->environment()  # Should be 'production'
   filter_var(env('SENTRY_REPORT_404', false), FILTER_VALIDATE_BOOLEAN)  # Should be true
   ```

2. **Verify Sentry integration:**
   ```bash
   php artisan tinker
   class_exists(\Sentry\Laravel\Integration::class)  # Should be true
   ```

3. **Check environment:**
   - 404s only report in production by default
   - To enable in other environments, modify `bootstrap/app.php`

4. **Check Sentry configuration:**
   ```bash
   php artisan sentry:test
   ```

5. **Check filters:**
   - Your 404 might be filtered out
   - Check the filtering logic in `bootstrap/app.php`

### Too Many 404s

If you're getting too many 404s:

1. **Add more bot patterns** to the filter
2. **Enable rate limiting** (see Example 3 above)
3. **Filter by referrer** - Ignore 404s from external sites
4. **Filter by path patterns** - Ignore specific URL patterns

---

## Production Setup

**Add to production `.env`:**
```env
SENTRY_REPORT_404=true
```

**After adding:**
```bash
php artisan config:clear
# Restart application
```

---

## Alternative: Manual 404 Reporting

If you want more control, you can manually report specific 404s:

```php
use Sentry\State\Scope;

if ($exception instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
    \Sentry\configureScope(function (Scope $scope) use ($exception) {
        $scope->setTag('404_path', request()->path());
        $scope->setContext('404_info', [
            'url' => request()->fullUrl(),
            'referrer' => request()->header('referer'),
            'user_agent' => request()->userAgent(),
        ]);
    });
    
    \Sentry\captureException($exception);
}
```

---

## Summary

- ✅ 404 reporting is **opt-in** via `SENTRY_REPORT_404=true`
- ✅ **Smart filtering** prevents bot noise
- ✅ Only reports in **production** by default
- ✅ Easy to customize filtering rules
- ✅ Helps identify broken links and user navigation issues

---

**Last Updated:** 2025-01-XX

