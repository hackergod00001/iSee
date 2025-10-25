#!/bin/bash

# Validate GitHub Actions Workflows
# This script checks YAML syntax and GitHub Actions validity

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          GitHub Actions Workflow Validator                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

WORKFLOWS_DIR=".github/workflows"
ERRORS=0

# Check if workflows directory exists
if [ ! -d "$WORKFLOWS_DIR" ]; then
    echo "❌ Workflows directory not found: $WORKFLOWS_DIR"
    exit 1
fi

echo "📁 Found workflows directory: $WORKFLOWS_DIR"
echo ""

# Count workflow files
WORKFLOW_COUNT=$(find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" | wc -l | xargs)
echo "📄 Total workflow files: $WORKFLOW_COUNT"
echo ""

# Check each workflow file
for workflow in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    # Skip if no files match
    [ -e "$workflow" ] || continue
    
    filename=$(basename "$workflow")
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Validating: $filename"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 1. Check file is readable
    if [ ! -r "$workflow" ]; then
        echo "❌ Cannot read file: $workflow"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    echo "✅ File is readable"
    
    # 2. Check YAML syntax with Python
    if command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
            echo "✅ Valid YAML syntax"
        else
            echo "❌ Invalid YAML syntax"
            python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>&1
            ERRORS=$((ERRORS + 1))
            continue
        fi
    else
        echo "⚠️  Python3 not found, skipping YAML syntax check"
    fi
    
    # 3. Check required GitHub Actions fields
    if ! grep -q "^name:" "$workflow"; then
        echo "❌ Missing 'name' field"
        ERRORS=$((ERRORS + 1))
    else
        WORKFLOW_NAME=$(grep "^name:" "$workflow" | head -1 | cut -d':' -f2- | xargs)
        echo "✅ Workflow name: $WORKFLOW_NAME"
    fi
    
    if ! grep -q "^on:" "$workflow"; then
        echo "❌ Missing 'on' trigger field"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ Has trigger configuration"
    fi
    
    if ! grep -q "^jobs:" "$workflow"; then
        echo "❌ Missing 'jobs' field"
        ERRORS=$((ERRORS + 1))
    else
        JOB_COUNT=$(grep -E "^  [a-z-]+:" "$workflow" | wc -l | xargs)
        echo "✅ Found $JOB_COUNT job(s)"
    fi
    
    # 4. Check for common issues
    if grep -q "uses: actions/checkout@v" "$workflow"; then
        echo "✅ Uses checkout action"
    else
        echo "⚠️  No checkout action found"
    fi
    
    # 5. Check actionlint if available
    if command -v actionlint &> /dev/null; then
        echo ""
        echo "Running actionlint..."
        if actionlint "$workflow" 2>&1; then
            echo "✅ actionlint validation passed"
        else
            echo "❌ actionlint found issues"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     Validation Summary                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Total workflows checked: $WORKFLOW_COUNT"
echo "Errors found: $ERRORS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ All workflows are valid!"
    echo ""
    echo "Next steps:"
    echo "  1. Commit and push to GitHub"
    echo "  2. Check the Actions tab: https://github.com/<your-repo>/actions"
    echo "  3. Trigger a test run by pushing to main/develop"
    exit 0
else
    echo "❌ Found $ERRORS error(s) in workflows"
    echo ""
    echo "Recommended fixes:"
    echo "  1. Review error messages above"
    echo "  2. Fix YAML syntax issues"
    echo "  3. Install actionlint: brew install actionlint"
    echo "  4. Run this script again"
    exit 1
fi

