#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"

echo "Testing: Merge commits are excluded from commit list"

test_dir=$(setup_test_repo)
cd "$test_dir"

echo "test" > file.txt
git add file.txt
git commit -q -m "feat: initial commit"

git checkout -q -b feature
echo "feature" > file2.txt
git add file2.txt
git commit -q -m "feat: add feature"

git checkout -q main
git merge --no-ff -q -m "Merge branch 'feature'" feature

template_file=$(mktemp)
editor_script=$(mktemp)
cat > "$editor_script" << EDITOREOF
#!/bin/bash
cp "\$1" "$template_file"
echo "v1.0.0" > "\$1"
EDITOREOF
chmod +x "$editor_script"

export GIT_EDITOR="$editor_script"
"$SCRIPT_DIR/../git-uptag" 2>&1 > /dev/null

if grep -q "Merge branch" "$template_file"; then
    echo "FAIL: Merge commit was included in template"
    cat "$template_file"
    rm "$editor_script" "$template_file"
    cleanup_test_repo "$test_dir"
    exit 1
fi

if ! grep -q "feat: add feature" "$template_file"; then
    echo "FAIL: Regular commit was not included"
    cat "$template_file"
    rm "$editor_script" "$template_file"
    cleanup_test_repo "$test_dir"
    exit 1
fi

rm "$editor_script" "$template_file"

echo "PASS: Merge commits are excluded"

cleanup_test_repo "$test_dir"
