#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"

echo "Testing: Minor version bump for feat"

test_dir=$(setup_test_repo)
cd "$test_dir"

echo "test" > file.txt
git add file.txt
git commit -q -m "feat: initial commit"
git tag v1.0.0

echo "feat" > file2.txt
git add file2.txt
git commit -q -m "feat: new feature"

editor_script=$(mktemp)
cat > "$editor_script" << 'EOF'
#!/bin/bash
# Accept whatever is pre-filled (should be v1.1.0)
exit 0
EOF
chmod +x "$editor_script"

export GIT_EDITOR="$editor_script"
"$SCRIPT_DIR/../git-uptag" > /dev/null 2>&1

assert_tag_exists "v1.1.0"

rm "$editor_script"

echo "PASS: Minor version bump for feat"

cleanup_test_repo "$test_dir"
