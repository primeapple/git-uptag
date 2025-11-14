#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running git-uptag tests..."
echo "=========================="
echo

failed=0
passed=0

for test in "$SCRIPT_DIR"/test/test_*.sh; do
    if [ "$(basename "$test")" = "test_helper.sh" ]; then
        continue
    fi
    
    timeout 10 bash "$test"
    if [ $? -eq 0 ]; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    echo
done

echo "=========================="
echo "Results: $passed passed, $failed failed"

if [ $failed -gt 0 ]; then
    exit 1
fi
