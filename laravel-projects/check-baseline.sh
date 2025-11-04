#!/bin/bash

# Quick script to check baseline error counts across projects

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PHPStan Baseline Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

BASE_DIR="/Users/jasonhill/Projects/laravel-projects"

# Moveroo-Cars-2026
if [ -f "$BASE_DIR/Moveroo-Cars-2026/phpstan-baseline.neon" ]; then
    COUNT=$(grep -c "message:" "$BASE_DIR/Moveroo-Cars-2026/phpstan-baseline.neon" 2>/dev/null || echo "0")
    echo "📊 Moveroo-Cars-2026: $COUNT errors"
    
    # Show top error types
    echo "   Top error types:"
    grep "identifier:" "$BASE_DIR/Moveroo-Cars-2026/phpstan-baseline.neon" 2>/dev/null | sed 's/.*identifier: //' | sort | uniq -c | sort -rn | head -3 | awk '{print "     • " $2 " (" $1 ")"}'
else
    echo "⚠️  Moveroo-Cars-2026: No baseline found"
fi

echo ""

# Moveroo Removals 2026
if [ -f "$BASE_DIR/Moveroo Removals 2026/phpstan-baseline.neon" ]; then
    COUNT=$(grep -c "message:" "$BASE_DIR/Moveroo Removals 2026/phpstan-baseline.neon" 2>/dev/null || echo "0")
    echo "📊 Moveroo Removals 2026: $COUNT errors"
    
    # Show top error types
    echo "   Top error types:"
    grep "identifier:" "$BASE_DIR/Moveroo Removals 2026/phpstan-baseline.neon" 2>/dev/null | sed 's/.*identifier: //' | sort | uniq -c | sort -rn | head -3 | awk '{print "     • " $2 " (" $1 ")"}'
else
    echo "⚠️  Moveroo Removals 2026: No baseline found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Tip: Update BASELINE-TRACKING.md after regenerating baselines"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

