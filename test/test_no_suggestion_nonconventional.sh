#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"

echo "Testing: No suggestion for non-conventional commits"

test_dir=$(setup_test_repo)
cd "$test_dir"

echo "test" > file.txt
git add file.txt
git commit -q -m "feat: initial commit"
git tag v1.0.0

echo "random" > file2.txt
git add file2.txt
git commit -q -m "random commit message"

template_file=$(mktemp)
editor_script=$(mktemp)
cat > "$editor_script" << EDITOREOF
#!/bin/bash
# Capture the template and provide a tag name
cp "\$1" "$template_file"
echo "v1.0.1" > "\$1"
EDITOREOF
chmod +x "$editor_script"

export GIT_EDITOR="$editor_script"
"$SCRIPT_DIR/../git-uptag.sh" > /dev/null 2>&1

# Check that the first line was empty (no suggestion)
first_line=$(head -n1 "$template_file")
if [ -n "$first_line" ]; then
    echo "FAIL: Should not have suggested a tag for non-conventional commits"
    echo "Got: '$first_line'"
    rm "$editor_script" "$template_file"
    cleanup_test_repo "$test_dir"
    exit 1
fi

rm "$editor_script" "$template_file"

echo "PASS: No suggestion for non-conventional commits"

cleanup_test_repo "$test_dir"
