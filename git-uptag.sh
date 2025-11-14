#!/bin/bash

set -euo pipefail

TEMP_FILE=$(mktemp)
echo "# Enter tag name on first line, then description after blank line" > "$TEMP_FILE"
echo "# Lines starting with # will be ignored" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

${GIT_EDITOR:-${VISUAL:-${EDITOR:-vi}}} "$TEMP_FILE"

TAG_NAME=$(grep -v "^#" "$TEMP_FILE" | head -n1 | xargs)
MESSAGE=$(grep -v "^#" "$TEMP_FILE" | tail -n +3 | sed "/^$/d;/^[[:space:]]*$/d")

if [ -z "$TAG_NAME" ]; then
    echo "Error: No tag name provided"
    rm "$TEMP_FILE"
    exit 1
fi

if [ -z "$MESSAGE" ]; then
    git tag "$TAG_NAME" "${1:-HEAD}"
    echo "Created lightweight tag: $TAG_NAME"
else
    echo "$MESSAGE" | git tag -a "$TAG_NAME" -F - "${1:-HEAD}"
    echo "Created annotated tag: $TAG_NAME"
fi

rm "$TEMP_FILE"
