# Laravel Telescope Setup Guide

**Purpose:** Complete setup guide for Laravel Telescope debugging and monitoring tool.

---

## Overview

Laravel Telescope is a debugging and monitoring tool that provides insights into:
- **Requests**: HTTP requests, responses, headers
- **Queries**: Database queries with bindings and execution time
- **Jobs**: Queue jobs and their status
- **Events**: Application events and listeners
- **Logs**: Application logs
- **Exceptions**: Errors and stack traces
- **Dumps**: `dd()` and `dump()` output
- **Cache**: Cache operations
- **Mail**: Email sending
- **Notifications**: Notification delivery
- **Models**: Eloquent model operations

---

## Installation

```bash
# Install Telescope
composer require laravel/telescope

# Publish Telescope assets and migrations
php artisan telescope:install

# Run migrations
php artisan migrate
```

---

## Access

### Local Development
- **URL**: `http://localhost:8000/telescope` (or your configured path)
- **Access**: Open to all authenticated users in `local` environment (configurable)

### Production/Staging
- **URL**: `https://your-domain.com/telescope` (or your configured path)
- **Access**: Restricted to users with appropriate roles (configurable)

---

## Configuration

### Environment Variables

Add to `.env`:

```env
# Enable/disable Telescope
TELESCOPE_ENABLED=true

# Telescope path (default: telescope)
TELESCOPE_PATH=telescope

# Optional: Subdomain for Telescope
# TELESCOPE_DOMAIN=telescope

# Production filtering mode (default: balanced)
# Options: 'minimal' (only errors), 'balanced' (errors + important), 'detailed' (most data)
TELESCOPE_FILTER_MODE=balanced
```

### Production Settings

In production, Telescope filtering is configurable via `TELESCOPE_FILTER_MODE`:

**Filtering Modes:**

1. **`minimal`** (most restrictive, lowest database usage)
   - Only records: exceptions, failed requests/jobs, scheduled tasks, monitored tags
   - Best for: High-traffic sites where you only need error tracking

2. **`balanced`** (default, recommended)
   - Records: All from `minimal` PLUS:
     - Slow queries (> 100ms)
     - Requests with errors (4xx, 5xx status codes)
     - Important jobs (email processing, notifications, etc.)
     - Mail sending
     - Error-level logs
   - Best for: Most production environments - good balance of visibility and performance

3. **`detailed`** (most data, highest database usage)
   - Records: Almost everything (except health checks and ignored paths)
   - Best for: Debugging specific issues or low-traffic sites
   - ⚠️ **Warning**: Can generate significant database load on high-traffic sites

**Security:**
- Sensitive data is always hidden (tokens, cookies, CSRF tokens)
- Requires appropriate role for access (configurable)
- See `app/Providers/TelescopeServiceProvider.php` for details

---

## Authorization

### Default Setup

Telescope access is controlled by the `viewTelescope` gate in `TelescopeServiceProvider`:

- **Local environment**: All authenticated users can access (configurable)
- **Production/Staging**: Only users with appropriate roles can access (configurable)

### Customizing Access

To customize access, update `app/Providers/TelescopeServiceProvider.php`:

```php
protected function gate(): void
{
    Gate::define('viewTelescope', function ($user) {
        // Option 1: Use role-based access (recommended)
        if (method_exists($user, 'hasRole')) {
            return $user->hasRole('admin') || $user->hasRole('super-admin') || $user->hasRole('developer');
        }
        
        // Option 2: Use email-based access
        return in_array($user->email, [
            'admin@example.com',
            'developer@example.com',
        ]);
        
        // Option 3: Environment-based
        if (app()->environment('local')) {
            return true; // Allow all authenticated users in local
        }
        
        // Production: require specific roles
        return $user->hasRole('admin');
    });
}
```

---

## Data Storage

Telescope stores data in the database:
- **Table**: `telescope_entries`
- **Tags**: `telescope_entries_tags`
- **Monitoring**: `telescope_monitoring`

### Pruning Old Data

Telescope can accumulate a lot of data. Prune old entries:

```bash
# Prune entries older than 24 hours
php artisan telescope:prune

# Prune entries older than 1 week
php artisan telescope:prune --hours=168
```

### Scheduled Pruning

Add to `app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule)
{
    // Prune Telescope entries older than 1 week
    $schedule->command('telescope:prune --hours=168')
        ->daily()
        ->at('04:00');
}
```

---

## Performance Considerations

### Production Filtering

Telescope is configured to only log important entries in production (when using `balanced` or `minimal` mode):

- ✅ Exceptions
- ✅ Failed requests
- ✅ Failed jobs
- ✅ Scheduled tasks
- ✅ Monitored tags
- ✅ Slow queries (> 100ms) - in balanced mode
- ✅ Error requests (4xx, 5xx) - in balanced mode
- ✅ Important jobs - in balanced mode

This reduces database load while still capturing critical issues.

### Disable Specific Watchers

You can disable specific watchers in `config/telescope.php` or via environment variables:

```env
# Disable specific watchers
TELESCOPE_CACHE_WATCHER=false
TELESCOPE_VIEW_WATCHER=false
TELESCOPE_DUMP_WATCHER=false
```

---

## Monitoring Specific Tags

You can monitor specific tags to always capture certain operations:

```php
use Laravel\Telescope\Telescope;

// In your code
Telescope::tag(function ($entry) {
    return ['important-operation'];
});
```

Entries with monitored tags are always stored, even in production.

---

## Integration with Other Tools

### Horizon
Telescope automatically tracks Horizon queue jobs when both are installed.

### Sentry
Telescope complements Sentry by providing detailed request/query context for errors.

---

## Security Notes

1. **Never expose Telescope in production without authentication**
   - Always configure proper access control ✅

2. **Sensitive data is hidden in production**
   - Tokens, cookies, CSRF tokens are automatically hidden ✅

3. **Consider IP whitelisting for additional security**
   - Can be added via middleware if needed

4. **Regularly prune old data**
   - Prevents database bloat
   - Reduces exposure of historical data

---

## Troubleshooting

### Telescope Not Showing Data

1. **Check if Telescope is enabled:**
   ```bash
   php artisan config:show telescope.enabled
   ```

2. **Check your filter mode (production):**
   ```bash
   php artisan tinker
   >>> env('TELESCOPE_FILTER_MODE', 'balanced')
   ```
   - If set to `minimal`, you'll only see errors/failures
   - Try `balanced` or `detailed` for more data
   - Update `.env`: `TELESCOPE_FILTER_MODE=balanced`
   - Clear config: `php artisan config:clear`

3. **Check database connection:**
   ```bash
   php artisan migrate:status
   ```

4. **Verify Telescope tables exist:**
   ```bash
   php artisan tinker
   >>> DB::table('telescope_entries')->count()
   ```

5. **Clear config cache:**
   ```bash
   php artisan config:clear
   ```

### Access Denied

1. **Check user role:**
   ```bash
   php artisan tinker
   >>> $user = User::find(1);
   >>> $user->hasRole('admin');
   ```

2. **Verify gate definition:**
   - Check `app/Providers/TelescopeServiceProvider.php`
   - Ensure `gate()` method is correct

### High Database Usage

1. **Enable production filtering** (use `balanced` or `minimal` mode)
2. **Prune old entries regularly**
3. **Disable unnecessary watchers**

---

## Testing Telescope

### Quick Test Command

Use the built-in test command to verify Telescope is working:

```bash
# Run all tests
php artisan telescope:test

# Run only basic configuration check
php artisan telescope:test --mode=basic

# Test specific features
php artisan telescope:test --mode=requests
php artisan telescope:test --mode=queries
php artisan telescope:test --mode=jobs
php artisan telescope:test --mode=mail
php artisan telescope:test --mode=logs
```

### Manual Testing Steps

#### 1. Verify Basic Setup

```bash
# Check if Telescope is enabled
php artisan config:show telescope.enabled

# Check filter mode
php artisan tinker
>>> env('TELESCOPE_FILTER_MODE', 'balanced')

# Check database tables exist
php artisan tinker
>>> DB::table('telescope_entries')->count()
```

#### 2. Test Request Recording

**In Local Environment:**
- Visit any page on your application
- Check Telescope dashboard at `/telescope`
- You should see the request in the "Requests" tab

**In Production (Balanced Mode):**
- Make a request that returns an error (4xx or 5xx status)
- Or trigger an exception
- Check Telescope dashboard - you should see error requests

#### 3. Test Query Recording

**In Local Environment:**
- Any database query should be recorded

**In Production (Balanced Mode):**
- Only slow queries (> 100ms) are recorded
- To test, execute a query that takes > 100ms

#### 4. Test Exception Recording

**All Environments:**
- Exceptions are always recorded (if Telescope is enabled)

**Test:**
```bash
# Create a test route that throws an exception
# Or use tinker:
php artisan tinker
>>> throw new \Exception('Telescope test exception');
```

Then check the Telescope dashboard - you should see the exception.

#### 5. Test Job Recording

**In Local Environment:**
- All jobs are recorded

**In Production (Balanced Mode):**
- Only important jobs are recorded
- Failed jobs are always recorded

#### 6. Test Mail Recording

**In Local Environment:**
- All mail is recorded

**In Production (Balanced Mode):**
- All mail is recorded (mail is considered important)

#### 7. Test Log Recording

**In Local Environment:**
- All logs are recorded

**In Production (Balanced Mode):**
- Only error-level logs (error, critical, alert, emergency) are recorded

### Verify Data in Telescope Dashboard

1. **Access the Dashboard:**
   - Local: `http://localhost:8000/telescope`
   - Production: `https://your-domain.com/telescope` (requires appropriate role)

2. **Check Each Tab:**
   - **Requests**: Should show HTTP requests (filtered by mode)
   - **Queries**: Should show database queries (filtered by mode)
   - **Jobs**: Should show queue jobs (filtered by mode)
   - **Mail**: Should show sent emails
   - **Logs**: Should show application logs (filtered by mode)
   - **Exceptions**: Should show all exceptions
   - **Commands**: Should show Artisan commands

3. **Verify Filter Mode Behavior:**
   - **Minimal Mode**: Only exceptions, failed requests/jobs, scheduled tasks
   - **Balanced Mode**: Exceptions, failed requests/jobs, slow queries, error requests, important jobs, all mail, error-level logs
   - **Detailed Mode**: Almost everything (except health checks)

### Testing Checklist

- [ ] Telescope is enabled (`php artisan config:show telescope.enabled`)
- [ ] Database tables exist (`telescope_entries` table has data)
- [ ] Can access dashboard at `/telescope`
- [ ] Requests are being recorded (check filter mode)
- [ ] Queries are being recorded (check filter mode)
- [ ] Exceptions are being recorded
- [ ] Jobs are being recorded (check filter mode)
- [ ] Mail is being recorded
- [ ] Logs are being recorded (check filter mode)
- [ ] Filter mode is set correctly for your environment

---

## Useful Commands

```bash
# Install Telescope
composer require laravel/telescope
php artisan telescope:install
php artisan migrate

# Test Telescope functionality
php artisan telescope:test                    # Run all tests
php artisan telescope:test --mode=basic       # Quick configuration check
php artisan telescope:test --mode=requests    # Test request recording
php artisan telescope:test --mode=queries      # Test query recording
php artisan telescope:test --mode=jobs        # Test job recording
php artisan telescope:test --mode=mail         # Test mail recording
php artisan telescope:test --mode=logs        # Test log recording

# Prune old entries
php artisan telescope:prune
php artisan telescope:prune --hours=168

# Clear Telescope cache
php artisan telescope:clear

# Check Telescope status
php artisan config:show telescope
php artisan config:show telescope.enabled
```

---

## Resources

- [Laravel Telescope Documentation](https://laravel.com/docs/telescope)
- [Telescope GitHub Repository](https://github.com/laravel/telescope)

---

## Summary

✅ **Installed**: Laravel Telescope  
✅ **Configured**: Role-based access control  
✅ **Production Ready**: Filtering enabled, sensitive data hidden  
✅ **Database**: Migrations run successfully  

**Next Steps:**
1. Access Telescope at `/telescope` (requires appropriate role in production)
2. Set up scheduled pruning: `php artisan telescope:prune --hours=168`
3. Monitor performance and adjust watchers as needed
4. Run `php artisan telescope:test` to verify everything is working

---

**Last Updated:** 2025-01-XX

