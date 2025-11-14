# CodeRabbit Cursor Integration Setup

**Reference:** [CodeRabbit Cursor Integration Documentation](https://docs.coderabbit.ai/cli/cursor-integration)

---

## Current Status

✅ **CodeRabbit CLI Installed** - Located at `~/.local/bin/coderabbit`  
❌ **Not Authenticated** - Need to run `coderabbit auth login`  
❌ **Cursor Rule Missing** - Need to add CodeRabbit rule to `.cursorrules`

---

## Setup Steps

### Step 1: Authenticate CodeRabbit

Run this command in your terminal:

```bash
coderabbit auth login
```

This will:
1. Provide a URL to open in your browser
2. Log in via your Git provider (GitHub, GitLab, etc.)
3. Copy the authentication token
4. Paste it back into the terminal

**Note:** 
- Free accounts get limited reviews per hour
- Pro accounts get higher limits and more comprehensive reviews
- See [pricing](https://www.coderabbit.ai/pricing) for details

### Step 2: Verify Authentication

After authenticating, verify it worked:

```bash
coderabbit auth status
```

You should see:
```
✅ Authentication: Logged in
```

### Step 3: Test Cursor Integration

Open Cursor chat (Command + L) and test:

```
Let's verify you can run the CodeRabbit CLI. Run the terminal command: coderabbit auth status and tell me the output.
```

### Step 4: Cursor Rule Added

A CodeRabbit rule has been added to `.cursorrules` in this repository. This tells Cursor:
- How to use CodeRabbit CLI
- To use `--prompt-only` flag for AI-optimized output
- To review uncommitted changes with `-t uncommitted`
- To limit reviews to 3 times per set of changes (to manage cost, time, and avoid diminishing returns from excessive iterations)

---

## Usage Workflow

### Basic Workflow

1. **Implement a feature** (via Cursor)
2. **Run CodeRabbit review:**
   ```
   Please implement phase 7.3 of the planning doc and then run coderabbit --prompt-only -t uncommitted, let it run as long as it needs and fix any issues.
   ```
3. **Cursor runs CodeRabbit** (takes 7-30 minutes depending on changes)
4. **Cursor reads results** and creates a task list
5. **Cursor fixes issues** automatically
6. **Repeat** until all issues resolved (max 3 times)

### Example: Payment Webhook Implementation

```bash
# 1. Start feature branch
git checkout -b feature/payment-webhooks

# 2. Tell Cursor to implement and review
# (In Cursor chat)
Implement the payment webhook handler from the spec document.
Then run coderabbit --prompt-only -t uncommitted, review the suggestions then fix any critical issues. Ignore nits.
```

CodeRabbit will identify:
- Missing signature verification
- Race conditions
- Insufficient error handling
- Security vulnerabilities

Cursor will then fix these automatically.

---

## CodeRabbit Commands

### Review Uncommitted Changes (Most Common)
```bash
coderabbit --prompt-only -t uncommitted
# or
coderabbit --prompt-only --type uncommitted
```

### Review Committed Changes
```bash
coderabbit --prompt-only -t committed
# or
coderabbit --prompt-only --type committed
```

### Review All Changes
```bash
coderabbit --prompt-only -t all
# or
coderabbit --prompt-only --type all
```

### Review Against Different Base Branch
```bash
coderabbit --prompt-only --base develop
```

### Help
```bash
coderabbit -h
# or
cr -h
```

---

## Optimization Tips

### Use `--prompt-only` Mode

Always use `--prompt-only` when running CodeRabbit from Cursor:
- Provides succinct issue context
- Token-efficient formatting
- Includes file locations and line numbers
- Suggests fix approaches

### Review Smaller Changesets

To reduce review time (7-30+ minutes):
- Use `-t uncommitted` (or `--type uncommitted`) to review only working directory changes
- Work on smaller feature branches
- Break large features into smaller chunks

### Configure CodeRabbit Preferences

CodeRabbit automatically reads your `.cursorrules` file, so you can add:
- Coding standards
- Architectural preferences
- Review instructions

---

## Troubleshooting

### CodeRabbit Not Finding Issues

1. **Check authentication:**
   ```bash
   coderabbit auth status
   ```
   (Authentication improves review quality but isn't required)

2. **Verify git status:**
   ```bash
   git status
   ```
   CodeRabbit analyzes tracked changes

3. **Check review type:**
   - Use `-t uncommitted` (or `--type uncommitted`) for uncommitted changes
   - Use `-t committed` (or `--type committed`) for committed changes
   - Use `-t all` (or `--type all`) for both (default)

4. **Specify base branch:**
   ```bash
   coderabbit --base develop
   ```
   (If your main branch isn't `main`)

5. **Review file types:**
   - CodeRabbit focuses on code files, not docs or config

### Review Taking Too Long

CodeRabbit reviews take 7-30+ minutes depending on scope:

1. **Ensure background execution** - Configure Cursor to run CodeRabbit in background
2. **Review smaller changesets:**
   - Use `-t uncommitted` (or `--type uncommitted`) for only working directory changes
   - Work on focused feature branches
   - Break large features into smaller chunks

3. **Configure diff scope:**
   - Use `--base develop` or `--base main` to set comparison point
   - Use feature branches instead of large staging branches

---

## Integration Benefits

### Expert Issue Detection
- Spots race conditions, memory leaks, and logic errors
- Same pattern recognition as PR reviews

### AI-Powered Fixes
- Cursor implements fixes with full context
- Handles complex architectural changes intelligently

### Context Preservation
- `--prompt-only` mode gives Cursor succinct context
- Includes location, severity, and suggested approaches

### Agentic Development Loop
- AI codes → reviews → fixes → iterates
- All before you even look at the code

---

## Next Steps

1. ✅ **Authenticate:** Run `coderabbit auth login`
2. ✅ **Verify:** Run `coderabbit auth status`
3. ✅ **Test:** Ask Cursor to run `coderabbit auth status`
4. ✅ **Use:** Start using in your development workflow

---

## Resources

- [CodeRabbit Cursor Integration Docs](https://docs.coderabbit.ai/cli/cursor-integration)
- [CodeRabbit Pricing](https://www.coderabbit.ai/pricing)
- [CodeRabbit CLI Overview](https://docs.coderabbit.ai/cli/overview)

---

**Last Updated:** 2025-01-XX

