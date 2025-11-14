#!/bin/bash

# Install Pre-Commit Hook Script
# Copies the master pre-commit hook from scripts/ to .git/hooks/pre-commit

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LARAVEL_PROJECTS_DIR="$(dirname "$SCRIPT_DIR")"
MASTER_HOOK="$SCRIPT_DIR/pre-commit-hook.sh"

# Check if we're in a Laravel project
if [ ! -f "artisan" ]; then
    echo -e "${RED}Error: This script must be run from a Laravel project root directory${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

PROJECT_DIR="$(pwd)"
GIT_HOOKS_DIR="$PROJECT_DIR/.git/hooks"
TARGET_HOOK="$GIT_HOOKS_DIR/pre-commit"

# Parse command line arguments
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--dry-run] [--force]"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Installing Pre-Commit Hook${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Project: ${GREEN}$(basename "$PROJECT_DIR")${NC}"
echo -e "Master hook: ${GREEN}$MASTER_HOOK${NC}"
echo -e "Target: ${GREEN}$TARGET_HOOK${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No files will be modified${NC}"
    echo ""
fi

# Check if master hook exists
if [ ! -f "$MASTER_HOOK" ]; then
    echo -e "${RED}Error: Master hook not found: $MASTER_HOOK${NC}"
    exit 1
fi

# Check if .git directory exists
if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo -e "${RED}Error: Not a git repository. Run 'git init' first.${NC}"
    exit 1
fi

# Check if hooks directory exists
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}Would create: $GIT_HOOKS_DIR${NC}"
    else
        mkdir -p "$GIT_HOOKS_DIR"
        echo -e "${GREEN}✅ Created hooks directory${NC}"
    fi
fi

# Check if hook already exists
if [ -f "$TARGET_HOOK" ]; then
    if [ "$FORCE" != true ] && [ "$DRY_RUN" != true ]; then
        echo -e "${YELLOW}⚠️  Pre-commit hook already exists at: $TARGET_HOOK${NC}"
        echo -e "${YELLOW}   Use --force to overwrite, or backup manually first${NC}"
        
        # Show diff if hook is different
        if ! cmp -s "$MASTER_HOOK" "$TARGET_HOOK"; then
            echo ""
            echo -e "${BLUE}Differences detected. Run with --force to update:${NC}"
            diff -u "$TARGET_HOOK" "$MASTER_HOOK" | head -20 || true
            echo ""
        fi
        
        exit 1
    else
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}Would backup existing hook: ${TARGET_HOOK}.backup.$(date +%Y%m%d_%H%M%S)${NC}"
        else
            BACKUP_PATH="${TARGET_HOOK}.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$TARGET_HOOK" "$BACKUP_PATH"
            echo -e "${GREEN}✅ Backed up existing hook to: $BACKUP_PATH${NC}"
        fi
    fi
fi

# Install the hook
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Would copy: $MASTER_HOOK → $TARGET_HOOK${NC}"
    echo -e "${YELLOW}Would make executable: chmod +x $TARGET_HOOK${NC}"
else
    cp "$MASTER_HOOK" "$TARGET_HOOK"
    chmod +x "$TARGET_HOOK"
    echo -e "${GREEN}✅ Hook installed successfully${NC}"
fi

# Verify installation
if [ "$DRY_RUN" != true ]; then
    if [ -f "$TARGET_HOOK" ] && [ -x "$TARGET_HOOK" ]; then
        echo -e "${GREEN}✅ Verification: Hook is installed and executable${NC}"
        
        # Check if hook content matches
        if cmp -s "$MASTER_HOOK" "$TARGET_HOOK"; then
            echo -e "${GREEN}✅ Verification: Hook content matches master version${NC}"
        else
            echo -e "${YELLOW}⚠️  Warning: Hook content differs from master (this shouldn't happen)${NC}"
        fi
    else
        echo -e "${RED}❌ Verification failed: Hook not found or not executable${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run complete. Run without --dry-run to install the hook.${NC}"
else
    echo -e "${GREEN}✅ Pre-commit hook installed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Test the hook: git commit --dry-run (or make a test commit)"
    echo "2. The hook will run automatically on every commit"
    echo "3. To update the hook, run this script again with --force"
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

