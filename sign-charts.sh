#!/bin/bash
set -e

# Helm Chart Signing Script
# Usage: ./sign-charts.sh

echo "🔐 Signing Helm Charts"
echo "======================"
echo ""

# Configuration
KEY_NAME="brian-gpg-key"  # Change this to your GPG key name or email
CHARTS_DIR="charts"
OUTPUT_DIR="docs"

# Check if GPG is available
if ! command -v gpg &> /dev/null; then
    echo "❌ Error: GPG is not installed"
    exit 1
fi

# Check if Helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ Error: Helm is not installed"
    exit 1
fi

# Check if key exists
if ! gpg --list-keys "$KEY_NAME" &> /dev/null; then
    echo "❌ Error: GPG key '$KEY_NAME' not found"
    echo ""
    echo "Available keys:"
    gpg --list-keys
    exit 1
fi

echo "Using GPG key: $KEY_NAME"
echo ""

# Check if legacy keyring exists, create if needed
if [ ! -f ~/.gnupg/pubring.gpg ] || [ ! -f ~/.gnupg/secring.gpg ]; then
    echo "⚙️  Creating legacy GPG keyring format for Helm..."
    gpg --export > ~/.gnupg/pubring.gpg
    gpg --export-secret-keys > ~/.gnupg/secring.gpg
    echo "✅ Legacy keyring created"
    echo ""
fi

# Package and sign each chart
for chart in $CHARTS_DIR/*; do
    if [ -d "$chart" ]; then
        chart_name=$(basename "$chart")
        echo "📦 Packaging and signing: $chart_name"
        
        # Package and sign
        helm package --sign --key "$KEY_NAME" "$chart" -d "$OUTPUT_DIR/"
        
        echo "✅ $chart_name signed successfully"
        echo ""
    fi
done

# Update repository index
echo "📝 Updating repository index..."
helm repo index $OUTPUT_DIR/ --url https://shared-infrastructure.github.io/helm-utils/

echo ""
echo "✅ All charts signed successfully!"
echo ""
echo "📋 Generated files:"
ls -lh $OUTPUT_DIR/*.tgz $OUTPUT_DIR/*.tgz.prov 2>/dev/null || true
echo ""
echo "🚀 Next steps:"
echo "   git add docs/"
echo "   git commit -m \"Release signed Helm charts\""
echo "   git push"

