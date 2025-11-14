#!/bin/bash

# Setup Laravel Project Script
# Interactive wizard to set up a new Laravel project with centralized configurations

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

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Laravel Project Setup Wizard${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Project: ${GREEN}$PROJECT_NAME${NC}"
echo -e "Directory: ${GREEN}$PROJECT_DIR${NC}"
echo ""

# Default values
BASE_BRANCH="main"
HEAD_BRANCH="dev"
INSTALL_PRE_COMMIT=true
INSTALL_WORKFLOWS=true
INSTALL_CONFIGS=true

# Interactive prompts
echo -e "${BLUE}Configuration:${NC}"
echo ""

read -p "Base branch (default: main): " input_base
BASE_BRANCH=${input_base:-main}

read -p "Head branch (default: dev): " input_head
HEAD_BRANCH=${input_head:-dev}

echo ""
read -p "Install pre-commit hook? (Y/n): " input_precommit
if [[ "$input_precommit" =~ ^[Nn]$ ]]; then
    INSTALL_PRE_COMMIT=false
fi

echo ""
read -p "Install GitHub workflow templates? (Y/n): " input_workflows
if [[ "$input_workflows" =~ ^[Nn]$ ]]; then
    INSTALL_WORKFLOWS=false
fi

echo ""
read -p "Install config templates (.coderabbit.yaml)? (Y/n): " input_configs
if [[ "$input_configs" =~ ^[Nn]$ ]]; then
    INSTALL_CONFIGS=false
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Installing Components...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Install pre-commit hook
if [ "$INSTALL_PRE_COMMIT" = true ]; then
    echo -e "${BLUE}1. Installing pre-commit hook...${NC}"
    if [ -f "$SCRIPT_DIR/install-pre-commit-hook.sh" ]; then
        bash "$SCRIPT_DIR/install-pre-commit-hook.sh" --force
    else
        echo -e "  ${RED}Error: install-pre-commit-hook.sh not found${NC}"
    fi
    echo ""
fi

# Install workflow templates
if [ "$INSTALL_WORKFLOWS" = true ]; then
    echo -e "${BLUE}2. Installing GitHub workflow templates...${NC}"
    if [ -f "$SCRIPT_DIR/install-github-templates.sh" ]; then
        bash "$SCRIPT_DIR/install-github-templates.sh" \
            --base-branch "$BASE_BRANCH" \
            --head-branch "$HEAD_BRANCH" \
            --project-name "$PROJECT_NAME"
    else
        echo -e "  ${RED}Error: install-github-templates.sh not found${NC}"
    fi
    echo ""
fi

# Install config templates
if [ "$INSTALL_CONFIGS" = true ]; then
    echo -e "${BLUE}3. Installing config templates...${NC}"
    TEMPLATES_DIR="$LARAVEL_PROJECTS_DIR/.github-templates"
    
    # Install .coderabbit.yaml
    if [ -f "$TEMPLATES_DIR/.coderabbit.yaml.template" ]; then
        TARGET_CONFIG="$PROJECT_DIR/.coderabbit.yaml"
        if [ -f "$TARGET_CONFIG" ]; then
            BACKUP="${TARGET_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$TARGET_CONFIG" "$BACKUP"
            echo -e "  ${YELLOW}Backed up existing: $BACKUP${NC}"
        fi
        cp "$TEMPLATES_DIR/.coderabbit.yaml.template" "$TARGET_CONFIG"
        echo -e "  ${GREEN}✅ Installed .coderabbit.yaml${NC}"
    else
        echo -e "  ${YELLOW}⚠️  .coderabbit.yaml.template not found${NC}"
    fi
    echo ""
fi

# Create documentation link
echo -e "${BLUE}4. Creating documentation reference...${NC}"
DOCS_LINK="$PROJECT_DIR/README-SETUP.md"
if [ ! -f "$DOCS_LINK" ]; then
    cat > "$DOCS_LINK" << EOF
# Setup Documentation

This project uses centralized setup documentation.

## Quick Links

- **Sentry Setup**: [../docs/sentry/SETUP.md](../docs/sentry/SETUP.md)
- **Telescope Setup**: [../docs/telescope/SETUP.md](../docs/telescope/SETUP.md)
- **CodeRabbit Setup**: [../docs/coderabbit/SETUP.md](../docs/coderabbit/SETUP.md)
- **Git Workflows**: [../docs/git/WORKFLOWS.md](../docs/git/WORKFLOWS.md)
- **Pre-Commit Hooks**: [../docs/git/PRE-COMMIT-HOOKS.md](../docs/git/PRE-COMMIT-HOOKS.md)
- **Code Quality Standards**: [../code-quality-standards-guide.md](../code-quality-standards-guide.md)

## All Documentation

See [../docs/README.md](../docs/README.md) for complete documentation index.

EOF
    echo -e "  ${GREEN}✅ Created README-SETUP.md${NC}"
else
    echo -e "  ${YELLOW}⚠️  README-SETUP.md already exists${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Review installed configurations:"
if [ "$INSTALL_WORKFLOWS" = true ]; then
    echo "   - Check .github/workflows/ for installed workflows"
fi
if [ "$INSTALL_CONFIGS" = true ]; then
    echo "   - Check .coderabbit.yaml configuration"
fi
if [ "$INSTALL_PRE_COMMIT" = true ]; then
    echo "   - Test pre-commit hook: git commit --dry-run"
fi
echo ""
echo "2. Customize as needed for your project"
echo ""
echo "3. Set up GitHub secrets if needed:"
echo "   - ACTIONS_PR_TOKEN (Personal Access Token for PR creation)"
echo "   - Other secrets as required by your workflows"
echo ""
echo "4. Commit the changes:"
echo "   git add ."
echo "   git commit -m 'chore: set up centralized Laravel project configuration'"
echo ""
echo "5. See README-SETUP.md for links to all documentation"
echo ""

