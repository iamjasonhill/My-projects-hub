#!/bin/bash

# Laravel Boost Setup Script
# Automates Laravel Boost and Cursor configuration setup for Laravel projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the project directory (default to current directory)
PROJECT_DIR="${1:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
PROJECT_FULL_PATH=$(cd "$PROJECT_DIR" && pwd)

echo -e "${GREEN}🚀 Setting up Laravel Boost for: ${PROJECT_NAME}${NC}"
echo -e "   Path: ${PROJECT_FULL_PATH}"
echo ""

# Check if it's a Laravel project
if [ ! -f "$PROJECT_DIR/artisan" ]; then
    echo -e "${RED}❌ Error: Not a Laravel project (artisan file not found)${NC}"
    exit 1
fi

# Check if composer.json exists
if [ ! -f "$PROJECT_DIR/composer.json" ]; then
    echo -e "${RED}❌ Error: composer.json not found${NC}"
    exit 1
fi

# Step 1: Install Laravel Boost
echo -e "${YELLOW}📦 Step 1: Installing Laravel Boost...${NC}"
cd "$PROJECT_DIR"

if grep -q "laravel/boost" composer.json; then
    echo -e "   ✅ Laravel Boost already in composer.json"
else
    echo -e "   Installing Laravel Boost..."
    composer require laravel/boost
fi

# Step 2: Run boost:install
echo -e "${YELLOW}📋 Step 2: Running boost:install...${NC}"
php artisan boost:install

# Step 3: Create .cursor directory if it doesn't exist
echo -e "${YELLOW}📁 Step 3: Creating .cursor directory...${NC}"
mkdir -p "$PROJECT_DIR/.cursor"

# Step 4: Create MCP configuration
echo -e "${YELLOW}⚙️  Step 4: Creating MCP configuration...${NC}"
MCP_CONFIG="$PROJECT_DIR/.cursor/mcp.json"

# Escape the path for JSON
ESCAPED_PATH=$(echo "$PROJECT_FULL_PATH" | sed 's/"/\\"/g')

cat > "$MCP_CONFIG" << EOF
{
    "mcpServers": {
        "laravel-boost": {
            "command": "php",
            "args": [
                "artisan",
                "boost:mcp"
            ],
            "cwd": "$ESCAPED_PATH"
        }
    }
}
EOF

echo -e "   ✅ Created: .cursor/mcp.json"

# Step 5: Check if .cursorrules exists, offer to copy from template
echo -e "${YELLOW}📝 Step 5: Checking Cursor rules...${NC}"
if [ ! -f "$PROJECT_DIR/.cursorrules" ]; then
    TEMPLATE_RULES="$PROJECT_DIR/../Moveroo-Cars-2026/.cursorrules"
    if [ -f "$TEMPLATE_RULES" ]; then
        echo -e "   📋 Template found. Copy .cursorrules from Moveroo-Cars-2026? (y/n)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            cp "$TEMPLATE_RULES" "$PROJECT_DIR/.cursorrules"
            echo -e "   ✅ Copied .cursorrules"
        else
            echo -e "   ⏭️  Skipped .cursorrules (you can add it manually later)"
        fi
    else
        echo -e "   ⏭️  No template found. Skipping .cursorrules"
    fi
else
    echo -e "   ✅ .cursorrules already exists"
fi

# Step 6: Verify setup
echo -e "${YELLOW}🔍 Step 6: Verifying setup...${NC}"

# Check if boost:mcp command exists
if php artisan list | grep -q "boost:mcp"; then
    echo -e "   ✅ boost:mcp command available"
else
    echo -e "   ${RED}❌ boost:mcp command not found${NC}"
fi

# Check if MCP config exists
if [ -f "$MCP_CONFIG" ]; then
    echo -e "   ✅ MCP configuration exists"
else
    echo -e "   ${RED}❌ MCP configuration missing${NC}"
fi

# Check if guidelines exist
if [ -f "$PROJECT_DIR/.cursor/rules/laravel-boost.mdc" ]; then
    echo -e "   ✅ Laravel Boost guidelines exist"
else
    echo -e "   ${YELLOW}⚠️  Guidelines not found (run: php artisan boost:update)${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup complete for ${PROJECT_NAME}!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "   1. Restart Cursor to connect MCP server"
echo -e "   2. Verify MCP connection in Cursor"
echo -e "   3. Test Laravel Boost tools"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} Run 'php artisan boost:update' to update guidelines with latest package versions"
echo ""



