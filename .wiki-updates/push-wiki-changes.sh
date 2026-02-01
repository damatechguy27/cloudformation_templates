#!/bin/bash
# Script to push wiki changes to GitHub
# This script should be run after authentication is set up

WIKI_DIR="/home/runner/work/cloudformation_templates/cloudformation_templates.wiki"

echo "Pushing IAM Engineering Project wiki updates to GitHub..."
cd "$WIKI_DIR"

echo "Current git status:"
git status

echo ""
echo "Attempting to push to origin/master..."
git push origin master

if [ $? -eq 0 ]; then
    echo "✓ Wiki changes successfully pushed to GitHub!"
    echo "✓ The IAM-Engineering-Project wiki page is now updated with:"
    echo "  - Purpose explanation"
    echo "  - Hyperlinks to related wiki pages"
else
    echo "✗ Failed to push wiki changes"
    echo "Please ensure you have proper authentication configured"
    exit 1
fi
