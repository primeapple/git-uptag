#!/bin/bash

set -euo pipefail

get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since_tag() {
    local latest_tag="$1"
    if [ -n "$latest_tag" ]; then
        git log --no-merges --pretty=format:"- %s" "$latest_tag"..HEAD
    else
        git log --no-merges --pretty=format:"- %s"
    fi
}

parse_semver() {
    local tag="$1"
    local has_v=""
    local version="$tag"
    
    if [[ "$tag" =~ ^v(.+)$ ]]; then
        has_v="v"
        version="${BASH_REMATCH[1]}"
    fi
    
    if [[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        echo "$has_v|${BASH_REMATCH[1]}|${BASH_REMATCH[2]}|${BASH_REMATCH[3]}"
        return 0
    fi
    return 1
}

check_conventional_commits() {
    local latest_tag="$1"
    local commits
    
    if [ -n "$latest_tag" ]; then
        commits=$(git log --no-merges --pretty=format:"%s" "$latest_tag"..HEAD)
    else
        commits=$(git log --no-merges --pretty=format:"%s")
    fi
    
    while IFS= read -r commit; do
        if ! [[ "$commit" =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?:\ .+ ]]; then
            return 1
        fi
    done <<< "$commits"
    
    return 0
}

guess_next_tag() {
    local latest_tag="$1"
    
    if [ -z "$latest_tag" ]; then
        echo ""
        return
    fi
    
    local parsed=$(parse_semver "$latest_tag")
    if [ $? -ne 0 ]; then
        echo ""
        return
    fi
    
    if ! check_conventional_commits "$latest_tag"; then
        echo ""
        return
    fi
    
    IFS='|' read -r has_v major minor patch <<< "$parsed"
    
    local commits
    if [ -n "$latest_tag" ]; then
        commits=$(git log --no-merges --pretty=format:"%s" "$latest_tag"..HEAD)
    else
        commits=$(git log --no-merges --pretty=format:"%s")
    fi
    
    local has_breaking=false
    local has_feat=false
    
    while IFS= read -r commit; do
        if [[ "$commit" =~ ^[a-z]+(\(.+\))?!: ]] || [[ "$commit" =~ BREAKING\ CHANGE: ]]; then
            has_breaking=true
            break
        elif [[ "$commit" =~ ^feat(\(.+\))?: ]]; then
            has_feat=true
        fi
    done <<< "$commits"
    
    if [ "$has_breaking" = true ]; then
        major=$((major + 1))
        minor=0
        patch=0
    elif [ "$has_feat" = true ]; then
        minor=$((minor + 1))
        patch=0
    else
        patch=$((patch + 1))
    fi
    
    echo "${has_v}${major}.${minor}.${patch}"
}

create_editor_template() {
    local temp_file="$1"
    local latest_tag="$2"
    local suggested_tag="$3"
    
    if [ -n "$suggested_tag" ]; then
        echo "$suggested_tag" > "$temp_file"
    else
        echo "" > "$temp_file"
    fi
    echo "" >> "$temp_file"
    echo "# Commits since ${latest_tag:-beginning}:" >> "$temp_file"
    get_commits_since_tag "$latest_tag" >> "$temp_file"
}

parse_tag_name() {
    local temp_file="$1"
    grep -v "^#" "$temp_file" | head -n1 | xargs
}

parse_tag_message() {
    local temp_file="$1"
    grep -v "^#" "$temp_file" | tail -n +3 | sed "/^$/d;/^[[:space:]]*$/d"
}

validate_format() {
    local temp_file="$1"
    local message="$2"
    
    if [ -n "$message" ]; then
        local second_line=$(grep -v "^#" "$temp_file" | sed -n '2p')
        if [ -n "$second_line" ]; then
            echo "Error: Second line must be empty for annotated tags"
            return 1
        fi
    fi
    return 0
}

create_tag() {
    local tag_name="$1"
    local message="$2"
    local target="${3:-HEAD}"
    
    if [ -z "$message" ]; then
        git tag "$tag_name" "$target"
        echo "Created lightweight tag: $tag_name"
    else
        echo "$message" | git tag -a "$tag_name" -F - "$target"
        echo "Created annotated tag: $tag_name"
    fi
}

main() {
    local temp_file=$(mktemp)
    local latest_tag=$(get_latest_tag)
    local suggested_tag=$(guess_next_tag "$latest_tag")
    
    create_editor_template "$temp_file" "$latest_tag" "$suggested_tag"
    ${GIT_EDITOR:-${VISUAL:-${EDITOR:-vi}}} "$temp_file"
    
    local tag_name=$(parse_tag_name "$temp_file")
    local message=$(parse_tag_message "$temp_file")
    
    if [ -z "$tag_name" ]; then
        echo "Error: No tag name provided"
        rm "$temp_file"
        exit 1
    fi
    
    if ! validate_format "$temp_file" "$message"; then
        rm "$temp_file"
        exit 1
    fi
    
    create_tag "$tag_name" "$message" "${1:-HEAD}"
    rm "$temp_file"
}

main "$@"
