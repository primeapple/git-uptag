#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"

echo "Testing: Basic lightweight tag creation"

test_dir=$(setup_test_repo)
cd "$test_dir"

echo "test" > file.txt
git add file.txt
git commit -q -m "feat: initial commit"

editor_script=$(mktemp)
cat > "$editor_script" << 'EOF'
#!/bin/bash
sed -i '1s/.*/v1.0.0/' "$1"
EOF
chmod +x "$editor_script"

export GIT_EDITOR="$editor_script"
"$SCRIPT_DIR/../git-uptag"

assert_tag_exists "v1.0.0"

output=$(git tag -l v1.0.0)
assert_equals "v1.0.0" "$output" "Tag should exist"

rm "$editor_script"

echo "PASS: Basic lightweight tag creation"

cleanup_test_repo "$test_dir"
