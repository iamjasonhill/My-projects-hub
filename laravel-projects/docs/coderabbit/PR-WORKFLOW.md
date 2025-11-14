# CodeRabbit PR Workflow Setup

**Purpose:** Configure CodeRabbit to automatically review pull requests created by GitHub Actions workflows.

---

## Overview

CodeRabbit can automatically review pull requests when they are created. This guide covers:
- Setting up `.coderabbit.yaml` configuration
- Ensuring PRs are created as "ready" (not draft)
- Configuring GitHub Actions workflows
- Troubleshooting common issues

---

## Configuration File

### Create `.coderabbit.yaml`

Create `.coderabbit.yaml` in your project root:

```yaml
# CodeRabbit Configuration
# This file configures CodeRabbit to review PRs created by the auto-PR workflow

reviews:
  # Review draft PRs (if any are created as drafts)
  draft: true
  
  # Show review status in PR comments
  review_status: true
  
  # Auto-review settings
  auto_review: true
  require_approvals: 1
  
  # Don't ignore any usernames - review all PRs
  # This ensures PRs created by the PAT token (your username) are reviewed
  ignore_usernames: []
  
  # Paths to include in reviews
  paths_include:
    - "app/**"
    - "database/**"
    - "resources/views/**"
    - "routes/**"
    - "tests/**"
  
  # Paths to exclude from reviews
  paths_exclude:
    - "public/build/**"
    - "storage/**"
    - "vendor/**"
  
  suggestion_limit: 200
  inline: true

  auto_title_instructions: |
    Use clear, concise titles that summarize the main change in the pull request.
    Avoid generic titles like "fix" or "update".
    Mention the key component or feature touched by the change.
  
  # Review PRs with these labels
  labels:
    - "auto-pr"
    - "needs-review"
    - "dev-to-main"
    - "dependencies"
    - "npm"
    - "composer"
    - "ci"
    - "review: ai"
```

---

## GitHub Actions Workflow

### Ensure PRs Are Created as Ready

Your GitHub Actions workflow should create PRs as "ready" (not draft) so CodeRabbit can review them:

```yaml
name: Auto PR from Dev

on:
  push:
    branches:
      - dev

permissions:
  contents: read
  pull-requests: write

jobs:
  create-pr:
    runs-on: ubuntu-latest
    steps:
      - name: Ensure PR from dev to main exists (ready for review)
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.ACTIONS_PR_TOKEN }}
          script: |
            const owner = context.repo.owner;
            const repo = context.repo.repo;
            const head = 'dev';
            const base = 'main';

            // Check if an open PR already exists from dev -> main
            const { data: prs } = await github.rest.pulls.list({ 
              owner, repo, state: 'open', 
              head: `${owner}:${head}`, 
              base 
            });
            
            if (prs.length > 0) {
              const existing = prs[0];
              core.info(`Open PR already exists: #${existing.number}`);
              
              // Ensure it is marked as ready (not draft) so CodeRabbit can review it
              // Use the dedicated ready_for_review endpoint (pulls.update doesn't support draft field)
              if (existing.draft) {
                await github.rest.pulls.markReadyForReview({ 
                  owner, repo, 
                  pull_number: existing.number 
                });
                core.info(`✅ Converted PR #${existing.number} from draft to ready for review`);
              }
              
              return;
            }

            // Create PR as ready for review so CodeRabbit can review it
            const { data: pr } = await github.rest.pulls.create({
              owner,
              repo,
              title: 'Auto PR: dev → main',
              head,
              base,
              body: 'This PR was automatically created from pushes to `dev`.',
              draft: false  // Create as ready for review so CodeRabbit can review it
            });

            await github.rest.issues.addLabels({ 
              owner, repo, 
              issue_number: pr.number, 
              labels: ['auto-pr','needs-review'] 
            }).catch(()=>{});
```

### Key Points

1. **Create PRs as ready**: Use `draft: false` when creating PRs
2. **Convert existing drafts**: Use `pulls.markReadyForReview()` to convert draft PRs to ready
3. **Add labels**: Add labels that CodeRabbit is configured to review
4. **Use PAT token**: Use a Personal Access Token (PAT) instead of `GITHUB_TOKEN` if you want PRs to appear as authored by you

---

## Common Issues

### CodeRabbit Not Reviewing PRs

**Issue:** PRs are created but CodeRabbit doesn't review them.

**Solutions:**
1. **Check PR is not draft**: CodeRabbit reviews draft PRs only if `draft: true` is set in config
2. **Check labels**: Ensure PR has labels that match your `.coderabbit.yaml` configuration
3. **Check CodeRabbit is enabled**: Verify CodeRabbit is installed and configured for your repository
4. **Check PR author**: Some configurations ignore PRs from certain users

### PR Created as Draft

**Issue:** GitHub Actions creates PRs as drafts.

**Solution:** Update your workflow to use `draft: false`:

```yaml
const { data: pr } = await github.rest.pulls.create({
  owner,
  repo,
  title: 'Auto PR: dev → main',
  head,
  base,
  body: 'This PR was automatically created.',
  draft: false  // ✅ Create as ready
});
```

### Existing Draft PR Not Converted

**Issue:** Existing draft PRs aren't converted to ready.

**Solution:** Use `pulls.markReadyForReview()` instead of `pulls.update()`:

```yaml
// ✅ Correct way
if (existing.draft) {
  await github.rest.pulls.markReadyForReview({ 
    owner, repo, 
    pull_number: existing.number 
  });
}

// ❌ This doesn't work (pulls.update doesn't support draft field)
await github.rest.pulls.update({ 
  owner, repo, 
  pull_number: existing.number, 
  draft: false 
});
```

### CodeRabbit Configuration Error

**Issue:** `.coderabbit.yaml` has parsing errors.

**Solution:** 
1. Validate YAML syntax using an online YAML validator
2. Check indentation (YAML is sensitive to indentation)
3. Simplify configuration if needed (remove complex nested structures)
4. Check CodeRabbit logs for specific error messages

---

## Best Practices

1. **Always create PRs as ready**: Use `draft: false` in workflows
2. **Convert existing drafts**: Check for draft PRs and convert them
3. **Use appropriate labels**: Add labels that CodeRabbit recognizes
4. **Keep config simple**: Avoid overly complex `.coderabbit.yaml` configurations
5. **Test locally**: Test CodeRabbit configuration before deploying

---

## Verification

### Check PR Status

1. Go to your GitHub repository
2. Check the PR from `dev` → `main`
3. Verify it's **ready** (not draft)
4. Check it has appropriate labels

### Check CodeRabbit Review

1. Wait 5-10 minutes after PR creation
2. Check PR comments for CodeRabbit review
3. Verify review status appears in PR

### Check Configuration

1. Verify `.coderabbit.yaml` exists in repository root
2. Check YAML syntax is valid
3. Ensure labels match between config and PR

---

## Troubleshooting Checklist

- [ ] `.coderabbit.yaml` exists in repository root
- [ ] YAML syntax is valid (no parsing errors)
- [ ] PR is created as ready (`draft: false`)
- [ ] PR has appropriate labels
- [ ] CodeRabbit is installed for repository
- [ ] PR author is not in `ignore_usernames` list
- [ ] Wait 5-10 minutes for review to start

---

## Resources

- [CodeRabbit Configuration Docs](https://docs.coderabbit.ai/configuration)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub API - Pull Requests](https://docs.github.com/en/rest/pulls/pulls)

---

**Last Updated:** 2025-01-XX

