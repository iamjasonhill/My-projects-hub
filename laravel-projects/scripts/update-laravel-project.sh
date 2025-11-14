#!/bin/bash

# Update Laravel Project Script
# Syncs updates from central location to existing projects

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

# Check if we're in a Laravel project
if [ ! -f "artisan" ]; then
    echo -e "${RED}Error: This script must be run from a Laravel project root directory${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Parse command line arguments
UPDATE_HOOK=true
UPDATE_WORKFLOWS=true
UPDATE_CONFIGS=true
SHOW_DIFF=true
AUTO_APPLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-hook)
            UPDATE_HOOK=false
            shift
            ;;
        --no-workflows)
            UPDATE_WORKFLOWS=false
            shift
            ;;
        --no-configs)
            UPDATE_CONFIGS=false
            shift
            ;;
        --no-diff)
            SHOW_DIFF=false
            shift
            ;;
        --auto-apply)
            AUTO_APPLY=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--no-hook] [--no-workflows] [--no-configs] [--no-diff] [--auto-apply]"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Updating Laravel Project${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Project: ${GREEN}$PROJECT_NAME${NC}"
echo -e "Directory: ${GREEN}$PROJECT_DIR${NC}"
echo ""

UPDATES_AVAILABLE=false

# Check pre-commit hook
if [ "$UPDATE_HOOK" = true ]; then
    MASTER_HOOK="$SCRIPT_DIR/pre-commit-hook.sh"
    CURRENT_HOOK="$PROJECT_DIR/.git/hooks/pre-commit"
    
    if [ -f "$CURRENT_HOOK" ] && [ -f "$MASTER_HOOK" ]; then
        if ! cmp -s "$MASTER_HOOK" "$CURRENT_HOOK"; then
            UPDATES_AVAILABLE=true
            echo -e "${YELLOW}⚠️  Pre-commit hook update available${NC}"
            if [ "$SHOW_DIFF" = true ]; then
                echo -e "${BLUE}Differences:${NC}"
                diff -u "$CURRENT_HOOK" "$MASTER_HOOK" | head -30 || true
                echo ""
            fi
        else
            echo -e "${GREEN}✅ Pre-commit hook is up to date${NC}"
        fi
    elif [ ! -f "$CURRENT_HOOK" ] && [ -f "$MASTER_HOOK" ]; then
        UPDATES_AVAILABLE=true
        echo -e "${YELLOW}⚠️  Pre-commit hook not installed${NC}"
    fi
    echo ""
fi

# Check workflow templates
if [ "$UPDATE_WORKFLOWS" = true ]; then
    TEMPLATES_DIR="$LARAVEL_PROJECTS_DIR/.github-templates/workflows"
    WORKFLOWS_DIR="$PROJECT_DIR/.github/workflows"
    
    if [ -d "$TEMPLATES_DIR" ] && [ -d "$WORKFLOWS_DIR" ]; then
        for template in "$TEMPLATES_DIR"/*.template; do
            if [ -f "$template" ]; then
                template_name=$(basename "$template")
                output_name="${template_name%.template}"
                current_workflow="$WORKFLOWS_DIR/$output_name"
                
                if [ -f "$current_workflow" ]; then
                    # Compare (ignoring template variables)
                    # This is a simplified check - full comparison would need template variable replacement
                    echo -e "${BLUE}Checking: $output_name${NC}"
                    # For now, just note that manual comparison may be needed
                    echo -e "  ${YELLOW}ℹ️  Manual review recommended for workflow updates${NC}"
                fi
            fi
        done
    fi
    echo ""
fi

# Check config templates
if [ "$UPDATE_CONFIGS" = true ]; then
    TEMPLATES_DIR="$LARAVEL_PROJECTS_DIR/.github-templates"
    CURRENT_CONFIG="$PROJECT_DIR/.coderabbit.yaml"
    TEMPLATE_CONFIG="$TEMPLATES_DIR/.coderabbit.yaml.template"
    
    if [ -f "$CURRENT_CONFIG" ] && [ -f "$TEMPLATE_CONFIG" ]; then
        # Simple comparison (template may have variables)
        if ! cmp -s "$TEMPLATE_CONFIG" "$CURRENT_CONFIG"; then
            UPDATES_AVAILABLE=true
            echo -e "${YELLOW}⚠️  .coderabbit.yaml update available${NC}"
            if [ "$SHOW_DIFF" = true ]; then
                echo -e "${BLUE}Differences:${NC}"
                diff -u "$CURRENT_CONFIG" "$TEMPLATE_CONFIG" | head -30 || true
                echo ""
            fi
        else
            echo -e "${GREEN}✅ .coderabbit.yaml is up to date${NC}"
        fi
    fi
    echo ""
fi

# Apply updates
if [ "$UPDATES_AVAILABLE" = true ]; then
    if [ "$AUTO_APPLY" != true ]; then
        echo -e "${YELLOW}Updates are available. Apply them? (y/N):${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Update cancelled.${NC}"
            exit 0
        fi
    fi
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Applying Updates...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Update pre-commit hook
    if [ "$UPDATE_HOOK" = true ]; then
        if [ -f "$SCRIPT_DIR/install-pre-commit-hook.sh" ]; then
            echo -e "${BLUE}Updating pre-commit hook...${NC}"
            bash "$SCRIPT_DIR/install-pre-commit-hook.sh" --force
            echo ""
        fi
    fi
    
    # Update configs
    if [ "$UPDATE_CONFIGS" = true ]; then
        TEMPLATES_DIR="$LARAVEL_PROJECTS_DIR/.github-templates"
        CURRENT_CONFIG="$PROJECT_DIR/.coderabbit.yaml"
        TEMPLATE_CONFIG="$TEMPLATES_DIR/.coderabbit.yaml.template"
        
        if [ -f "$TEMPLATE_CONFIG" ]; then
            if [ -f "$CURRENT_CONFIG" ]; then
                BACKUP="${CURRENT_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$CURRENT_CONFIG" "$BACKUP"
                echo -e "${GREEN}✅ Backed up existing: $BACKUP${NC}"
            fi
            cp "$TEMPLATE_CONFIG" "$CURRENT_CONFIG"
            echo -e "${GREEN}✅ Updated .coderabbit.yaml${NC}"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Updates applied successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review the changes"
    echo "2. Test the updated hook: git commit --dry-run"
    echo "3. Commit the updates if satisfied"
    echo ""
else
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ All components are up to date!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

