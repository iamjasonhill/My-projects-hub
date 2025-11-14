# Git Workflows Documentation

**Purpose:** Documentation for GitHub Actions workflow templates and setup.

---

## Overview

This directory contains workflow templates that can be installed in Laravel projects to automate common Git operations, particularly automatic PR creation.

---

## Available Workflows

### Auto-PR from Dev to Main

**Template:** `.github-templates/workflows/auto-pr-dev-to-main.yml.template`

**Purpose:** Automatically creates or updates a pull request from `dev` branch to `main` branch whenever code is pushed to `dev`.

**Features:**
- Creates PRs as ready (not draft) so CodeRabbit can review
- Converts existing draft PRs to ready status
- Smart commit message parsing for PR titles
- Automatic label assignment
- Concurrency control to prevent duplicate PRs

**Installation:**
```bash
cd /path/to/laravel-project
/path/to/laravel-projects/scripts/install-github-templates.sh \
  --base-branch main \
  --head-branch dev \
  --project-name YourProjectName
```

**Customization:**
After installation, you can customize the workflow in `.github/workflows/auto-pr-dev-to-main.yml`:
- Change branch names
- Modify PR body template
- Adjust labels
- Add additional steps

---

## Installation Instructions

### Using the Install Script (Recommended)

```bash
cd /path/to/laravel-project
/path/to/laravel-projects/scripts/install-github-templates.sh \
  --base-branch main \
  --head-branch dev \
  --project-name YourProjectName
```

**Options:**
- `--base-branch BRANCH` - Base branch (default: main)
- `--head-branch BRANCH` - Head branch (default: dev)
- `--project-name NAME` - Project name for templates
- `--dry-run` - Show what would be done without making changes

### Manual Installation

1. Copy template from `.github-templates/workflows/`
2. Replace template variables:
   - `{{BASE_BRANCH}}` → your base branch
   - `{{HEAD_BRANCH}}` → your head branch
   - `{{PROJECT_NAME}}` → your project name
3. Save to `.github/workflows/` in your project
4. Remove `.template` extension

---

## Configuration

### GitHub Secrets

The workflows may require these secrets:

- **`ACTIONS_PR_TOKEN`** or **`PRDEVMAIN`** - Personal Access Token (PAT) for creating PRs
  - Create at: https://github.com/settings/tokens
  - Required scopes: `repo` (full control)
  - Used to make PRs appear as human-authored (prevents CodeRabbit from skipping)

### Workflow Permissions

The workflows require these permissions:
- `contents: write` - To read repository content
- `pull-requests: write` - To create/update PRs
- `issues: write` - To add labels

---

## Troubleshooting

### PRs Not Being Created

1. **Check workflow permissions:**
   - Go to Settings → Actions → General
   - Ensure "Workflow permissions" allows read/write access

2. **Check GitHub secrets:**
   - Verify `ACTIONS_PR_TOKEN` or `PRDEVMAIN` is set
   - Ensure token has correct permissions

3. **Check workflow logs:**
   - Go to Actions tab in GitHub
   - View workflow run logs for errors

### PRs Created as Draft

The workflow should create PRs as ready (`draft: false`). If they're still drafts:

1. Check workflow file has `draft: false` in `pulls.create()`
2. Verify `pulls.markReadyForReview()` is called for existing drafts
3. Check workflow logs for errors

### CodeRabbit Not Reviewing

1. Ensure PR is ready (not draft)
2. Check `.coderabbit.yaml` configuration
3. Verify PR has appropriate labels
4. Wait 5-10 minutes for CodeRabbit to start reviewing

---

## Best Practices

1. **Use PAT tokens** - Makes PRs appear as human-authored
2. **Create PRs as ready** - Use `draft: false` so CodeRabbit can review
3. **Convert existing drafts** - Use `markReadyForReview()` for existing PRs
4. **Add appropriate labels** - Helps CodeRabbit identify PRs to review
5. **Test workflows** - Use `workflow_dispatch` to test manually

---

## Customization Examples

### Change Branch Names

Edit `.github/workflows/auto-pr-dev-to-main.yml`:

```yaml
env:
  BASE_BRANCH: production  # Changed from main
  HEAD_BRANCH: staging     # Changed from dev
```

### Add Custom Labels

```yaml
await github.rest.issues.addLabels({ 
  owner, repo, 
  issue_number: pr.number, 
  labels: ['auto-pr','needs-review','custom-label'] 
});
```

### Modify PR Body

Edit the `body` variable in the workflow to customize the PR description.

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub API - Pull Requests](https://docs.github.com/en/rest/pulls/pulls)
- [CodeRabbit PR Workflow Guide](../coderabbit/PR-WORKFLOW.md)

---

**Last Updated:** 2025-01-XX

