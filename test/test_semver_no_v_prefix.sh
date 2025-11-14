#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"

echo "Testing: Tags without 'v' prefix"

test_dir=$(setup_test_repo)
cd "$test_dir"

echo "test" > file.txt
git add file.txt
git commit -q -m "feat: initial commit"
git tag 1.0.0

echo "fix" > file2.txt
git add file2.txt
git commit -q -m "fix: bug fix"

editor_script=$(mktemp)
cat > "$editor_script" << 'EOF'
#!/bin/bash
# Accept whatever is pre-filled (should be 1.0.1)
exit 0
EOF
chmod +x "$editor_script"

export GIT_EDITOR="$editor_script"
"$SCRIPT_DIR/../git-uptag.sh" > /dev/null 2>&1

assert_tag_exists "1.0.1"

rm "$editor_script"

echo "PASS: Tags without 'v' prefix"

cleanup_test_repo "$test_dir"
