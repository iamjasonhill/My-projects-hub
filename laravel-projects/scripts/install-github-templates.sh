#!/bin/bash

# Install GitHub Templates Script
# Copies workflow and config templates from .github-templates/ to project .github/ directory
# Replaces template variables with project-specific values

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
TEMPLATES_DIR="$LARAVEL_PROJECTS_DIR/.github-templates"

# Check if we're in a Laravel project
if [ ! -f "artisan" ]; then
    echo -e "${RED}Error: This script must be run from a Laravel project root directory${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
GITHUB_DIR="$PROJECT_DIR/.github"
WORKFLOWS_DIR="$GITHUB_DIR/workflows"

# Default values
BASE_BRANCH="main"
HEAD_BRANCH="dev"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --base-branch)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --head-branch)
            HEAD_BRANCH="$2"
            shift 2
            ;;
        --project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--base-branch BRANCH] [--head-branch BRANCH] [--project-name NAME] [--dry-run]"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Installing GitHub Templates${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Project: ${GREEN}$PROJECT_NAME${NC}"
echo -e "Base branch: ${GREEN}$BASE_BRANCH${NC}"
echo -e "Head branch: ${GREEN}$HEAD_BRANCH${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No files will be modified${NC}"
    echo ""
fi

# Check if templates directory exists
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo -e "${RED}Error: Templates directory not found: $TEMPLATES_DIR${NC}"
    exit 1
fi

# Create .github directory if it doesn't exist
if [ "$DRY_RUN" != true ]; then
    mkdir -p "$GITHUB_DIR"
    mkdir -p "$WORKFLOWS_DIR"
fi

# Function to replace template variables
replace_template_vars() {
    local file="$1"
    sed -e "s/{{BASE_BRANCH}}/$BASE_BRANCH/g" \
        -e "s/{{HEAD_BRANCH}}/$HEAD_BRANCH/g" \
        -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        "$file"
}

# Install workflow templates
if [ -d "$TEMPLATES_DIR/workflows" ]; then
    echo -e "${BLUE}Installing workflow templates...${NC}"
    
    for template in "$TEMPLATES_DIR/workflows"/*.template; do
        if [ -f "$template" ]; then
            template_name=$(basename "$template")
            output_name="${template_name%.template}"
            output_path="$WORKFLOWS_DIR/$output_name"
            
            echo -e "  Processing: ${YELLOW}$template_name${NC}"
            
            # Backup existing file if it exists
            if [ -f "$output_path" ] && [ "$DRY_RUN" != true ]; then
                backup_path="${output_path}.backup.$(date +%Y%m%d_%H%M%S)"
                echo -e "    ${YELLOW}Backing up existing: $backup_path${NC}"
                cp "$output_path" "$backup_path"
            fi
            
            if [ "$DRY_RUN" = true ]; then
                echo -e "    ${GREEN}Would create: $output_path${NC}"
                replace_template_vars "$template" | head -20
                echo -e "    ${YELLOW}... (truncated)${NC}"
            else
                replace_template_vars "$template" > "$output_path"
                echo -e "    ${GREEN}✅ Created: $output_path${NC}"
            fi
        fi
    done
fi

# Install config templates
echo -e "${BLUE}Installing config templates...${NC}"

for template in "$TEMPLATES_DIR"/*.template; do
    if [ -f "$template" ]; then
        template_name=$(basename "$template")
        output_name="${template_name%.template}"
        output_path="$PROJECT_DIR/$output_name"
        
        echo -e "  Processing: ${YELLOW}$template_name${NC}"
        
        # Backup existing file if it exists
        if [ -f "$output_path" ] && [ "$DRY_RUN" != true ]; then
            backup_path="${output_path}.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "    ${YELLOW}Backing up existing: $backup_path${NC}"
            cp "$output_path" "$backup_path"
        fi
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "    ${GREEN}Would create: $output_path${NC}"
            replace_template_vars "$template" | head -20
            echo -e "    ${YELLOW}... (truncated)${NC}"
        else
            replace_template_vars "$template" > "$output_path"
            echo -e "    ${GREEN}✅ Created: $output_path${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run complete. Run without --dry-run to apply changes.${NC}"
else
    echo -e "${GREEN}✅ GitHub templates installed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review the installed templates in .github/workflows/"
    echo "2. Customize as needed for your project"
    echo "3. Commit the changes to your repository"
    echo "4. Set up GitHub secrets if needed (ACTIONS_PR_TOKEN, etc.)"
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

