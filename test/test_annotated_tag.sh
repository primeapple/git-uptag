#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"

echo "Testing: Annotated tag with message"

test_dir=$(setup_test_repo)
cd "$test_dir"

echo "test" > file.txt
git add file.txt
git commit -q -m "feat: initial commit"

tag_input=$(mktemp)
cat > "$tag_input" << 'EOF'
v1.0.0

This is a test release
With multiple lines
EOF

editor_script=$(mktemp)
cat > "$editor_script" << EDITOREOF
#!/bin/bash
cat "$tag_input" > "\$1"
EDITOREOF
chmod +x "$editor_script"

export GIT_EDITOR="$editor_script"
"$SCRIPT_DIR/../git-uptag.sh"

assert_tag_exists "v1.0.0"

tag_type=$(git cat-file -t v1.0.0)
assert_equals "tag" "$tag_type" "Should be an annotated tag"

rm "$tag_input" "$editor_script"

echo "PASS: Annotated tag with message"

cleanup_test_repo "$test_dir"
