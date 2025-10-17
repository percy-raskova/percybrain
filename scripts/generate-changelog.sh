#!/bin/bash
# Generate CHANGELOG from git commits
# Usage: ./scripts/generate-changelog.sh v1.2.3

set -euo pipefail

TAG="${1:-}"

if [ -z "$TAG" ]; then
    echo "❌ Error: Tag argument required"
    echo "Usage: $0 <tag>"
    echo "Example: $0 v1.2.3"
    exit 1
fi

# Remove 'v' prefix for display
VERSION="${TAG#v}"

# Get previous tag (if exists)
PREV_TAG=$(git describe --tags --abbrev=0 "$TAG^" 2>/dev/null || echo "")

# Generate commit range
if [ -z "$PREV_TAG" ]; then
    echo "📝 First release - including all commits"
    COMMIT_RANGE=""
else
    echo "📝 Generating changelog from $PREV_TAG to $TAG"
    COMMIT_RANGE="$PREV_TAG..$TAG"
fi

# Get commit log
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"- %s (%h)" --reverse)
else
    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"- %s (%h)" --reverse)
fi

# Count commits
COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')

# Generate changelog file for GitHub release
cat > CHANGELOG-release.md << EOF
# Release $VERSION

Released on $(date -u +"%Y-%m-%d")

## What's Changed

$COMMITS

---

**Full Changelog**: https://github.com/\${GITHUB_REPOSITORY:-yourusername/percybrain}/compare/${PREV_TAG}...${TAG}

## Installation

\`\`\`lua
-- Using lazy.nvim
{
  "yourusername/percybrain",
  tag = "$TAG",
  config = function()
    require("config").setup()
  end,
}
\`\`\`

See [INSTALL-${VERSION}.md](./INSTALL-${VERSION}.md) for detailed installation instructions.

## Contributors

Thank you to everyone who contributed to this release! 🎉

---

*This changelog was automatically generated from git commits.*
EOF

# Also update main CHANGELOG.md (append to top)
if [ -f CHANGELOG.md ]; then
    # Prepend new release to existing changelog
    echo "Updating CHANGELOG.md..."

    # Create temporary file with new release
    cat > CHANGELOG-temp.md << EOF
# Changelog

All notable changes to PercyBrain will be documented in this file.

## [$VERSION] - $(date -u +"%Y-%m-%d")

### Changed

$COMMITS

EOF

    # Append existing changelog (skip first 3 lines if they exist)
    if [ "$(wc -l < CHANGELOG.md)" -gt 3 ]; then
        tail -n +4 CHANGELOG.md >> CHANGELOG-temp.md
    fi

    # Replace CHANGELOG.md
    mv CHANGELOG-temp.md CHANGELOG.md
else
    # Create new CHANGELOG.md
    echo "Creating CHANGELOG.md..."
    cat > CHANGELOG.md << EOF
# Changelog

All notable changes to PercyBrain will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [$VERSION] - $(date -u +"%Y-%m-%d")

### Changed

$COMMITS

EOF
fi

echo ""
echo "✅ Generated changelog files:"
echo "   - CHANGELOG-release.md (for GitHub release)"
echo "   - CHANGELOG.md (updated project changelog)"
echo ""
echo "📊 Statistics:"
echo "   - Version: $VERSION"
echo "   - Previous tag: ${PREV_TAG:-none (first release)}"
echo "   - Commits included: $COMMIT_COUNT"
echo ""
echo "📖 Changelog preview (first 20 lines):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -20 CHANGELOG-release.md
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
