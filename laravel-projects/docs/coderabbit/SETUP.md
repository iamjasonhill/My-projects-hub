# CodeRabbit Setup Guide

**Quick reference for setting up CodeRabbit CLI with Cursor in Laravel projects.**

---

## Prerequisites

- Cursor IDE installed
- Git repository initialized
- Terminal access

---

## Step 1: Install CodeRabbit CLI

```bash
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
source ~/.zshrc  # or ~/.bashrc for bash
```

**Verify installation:**
```bash
which coderabbit
# Should output: /Users/username/.local/bin/coderabbit
```

---

## Step 2: Authenticate

```bash
coderabbit auth login
```

This will:
1. Open a browser URL
2. Log in via your Git provider (GitHub, GitLab, etc.)
3. Copy the authentication token
4. Paste it back into the terminal

**Verify authentication:**
```bash
coderabbit auth status
```

Expected output:
```
✅ Authentication: Logged in
👤 User: your-username
🔗 Provider: github
```

---

## Step 3: Add Cursor Rule

Add this section to your project's `.cursorrules` file:

```markdown
---

## CodeRabbit Integration

### Running CodeRabbit CLI

CodeRabbit is already installed in the terminal. Run it as a way to review your code. Run the command: `coderabbit -h` for details on commands available.

**IMPORTANT:** When running CodeRabbit to review code changes, don't run it more than 3 times in a given set of changes.

### CodeRabbit Usage

- **For uncommitted changes (most common):** Run `coderabbit --prompt-only -t uncommitted`
- **For committed changes:** Run `coderabbit --prompt-only -t committed`
- **For all changes:** Run `coderabbit --prompt-only -t all`
- **With different base branch:** Run `coderabbit --prompt-only --base develop`

### CodeRabbit Workflow

When implementing features, use this pattern:
1. Implement the feature
2. Run `coderabbit --prompt-only -t uncommitted` to review changes
3. Let CodeRabbit run (may take 7-30 minutes depending on changes)
4. Read CodeRabbit's suggestions and create a task list
5. Fix issues systematically
6. Repeat if needed (max 3 times per set of changes)

### CodeRabbit Best Practices

- Always use `--prompt-only` flag for AI-optimized output
- Use `-t uncommitted` to review only working directory changes
- Focus on critical issues first, ignore nits if requested
- CodeRabbit provides succinct context including file locations and suggested fixes
```

---

## Step 4: Test Integration

Open Cursor chat (Command + L) and test:

```
Run coderabbit auth status and tell me the output.
```

Cursor should be able to execute the command and report the authentication status.

---

## Quick Verification Checklist

- [ ] CodeRabbit CLI installed (`which coderabbit` works)
- [ ] Authenticated (`coderabbit auth status` shows logged in)
- [ ] Cursor rule added to `.cursorrules`
- [ ] Cursor can run CodeRabbit commands (tested in chat)

---

## Usage Examples

### Basic Review Workflow

In Cursor chat:
```
Implement the new feature from the planning doc, then run coderabbit --prompt-only -t uncommitted and fix any critical issues.
```

### Quick Review of Current Changes

```
Run coderabbit --prompt-only -t uncommitted to review my uncommitted changes
```

### Review Against Different Base Branch

```
Run coderabbit --prompt-only --base develop to review changes against develop branch
```

---

## Common Commands

```bash
# Review uncommitted changes (most common)
coderabbit --prompt-only -t uncommitted

# Review committed changes
coderabbit --prompt-only -t committed

# Review all changes
coderabbit --prompt-only -t all

# Review against specific base branch
coderabbit --prompt-only --base develop

# Check authentication
coderabbit auth status

# Get help
coderabbit -h
```

---

## Troubleshooting

### CodeRabbit Not Found

```bash
# Reinstall
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
source ~/.zshrc
```

### Authentication Failed

```bash
# Re-authenticate
coderabbit auth login
```

### Cursor Can't Run CodeRabbit

1. Verify CodeRabbit is in PATH: `which coderabbit`
2. Restart Cursor
3. Test in Cursor chat: "Run coderabbit auth status"

### Review Taking Too Long

- Reviews take 7-30+ minutes depending on scope
- Use `-t uncommitted` to review only working directory changes
- Work on smaller feature branches
- Break large features into smaller chunks

---

## Notes

- **Free accounts:** Limited reviews per hour
- **Pro accounts:** Higher limits and more comprehensive reviews
- **Review limit:** Don't run more than 3 times per set of changes (cost, time, diminishing returns)
- **Always use `--prompt-only`:** Optimized for AI agents like Cursor

---

## Resources

- [CodeRabbit Cursor Integration Docs](https://docs.coderabbit.ai/cli/cursor-integration)
- [CodeRabbit Pricing](https://www.coderabbit.ai/pricing)
- [CodeRabbit CLI Overview](https://docs.coderabbit.ai/cli/overview)

---

**Setup Time:** ~5 minutes  
**One-time setup per machine** (authentication persists across projects)

---

**Last Updated:** 2025-01-XX

