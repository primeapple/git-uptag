#!/bin/bash

ORIGINAL_DIR="$PWD"

setup_test_repo() {
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "$test_dir"
}

cleanup_test_repo() {
    local test_dir="$1"
    cd "$ORIGINAL_DIR"
    rm -rf "$test_dir"
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [ "$expected" != "$actual" ]; then
        echo "FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual: '$actual'"
        exit 1
    fi
}

assert_tag_exists() {
    local tag="$1"
    if ! git tag | grep -q "^${tag}$"; then
        echo "FAIL: Tag '$tag' does not exist"
        exit 1
    fi
}

assert_tag_message() {
    local tag="$1"
    local expected_message="$2"
    local actual_message=$(git tag -n999 "$tag" | tail -n +2 | sed 's/^[[:space:]]*//')
    
    if [ "$expected_message" != "$actual_message" ]; then
        echo "FAIL: Tag message mismatch for '$tag'"
        echo "  Expected: '$expected_message'"
        echo "  Actual: '$actual_message'"
        exit 1
    fi
}
