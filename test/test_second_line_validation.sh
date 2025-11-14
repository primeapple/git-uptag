#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"

echo "Testing: Second line validation for annotated tags"

test_dir=$(setup_test_repo)
cd "$test_dir"

echo "test" > file.txt
git add file.txt
git commit -q -m "feat: initial commit"

tag_input=$(mktemp)
cat > "$tag_input" << 'EOF'
v1.0.0
This should be empty but is not
This is a test release
EOF

editor_script=$(mktemp)
cat > "$editor_script" << EDITOREOF
#!/bin/bash
cat "$tag_input" > "\$1"
EDITOREOF
chmod +x "$editor_script"

export GIT_EDITOR="$editor_script"
set +e
output=$("$SCRIPT_DIR/../git-uptag" 2>&1)
exit_code=$?
set -e

if echo "$output" | grep -q "Second line must be empty" && [ $exit_code -ne 0 ]; then
    echo "PASS: Second line validation works"
else
    echo "FAIL: Should have rejected non-empty second line"
    echo "Output: $output"
    echo "Exit code: $exit_code"
    rm "$tag_input" "$editor_script"
    cleanup_test_repo "$test_dir"
    exit 1
fi

rm "$tag_input" "$editor_script"
cleanup_test_repo "$test_dir"
