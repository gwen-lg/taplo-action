#!/bin/bash

set -euo pipefail

# Function to list commits for push events
list_push_commits() {
    local commits_list="["
    local first=true

    # Check if commits array is available
    if [ -z "${GITHUB_EVENT_COMMITS:-}" ]; then
        echo "Error: No commits found in push event" >&2
        exit 1
    fi

    # Process each commit from github.event.commits
    IFS=' ' read -ra COMMITS_ARRAY <<< "$GITHUB_EVENT_COMMITS"
    for commit in "${COMMITS_ARRAY[@]}"; do
        if [ "$first" = true ]; then
            commits_list="$commits_list\"$commit\""
            first=false
        else
            commits_list="$commits_list, \"$commit\""
        fi
    done
    commits_list="$commits_list]"
    echo "$commits_list"
}

# Function to list commits for pull_request events
list_pr_commits() {
    # Validate required environment variables
    if [ -z "${GITHUB_PR_BASE:-}" ] || [ -z "${GITHUB_PR_HEAD:-}" ]; then
        echo "Error: Missing PR base or head information" >&2
        exit 1
    fi

    # Use git rev-list to get commits between base and head
    if ! git rev-list "$GITHUB_PR_BASE".."$GITHUB_PR_HEAD" > /dev/null 2>&1; then
        echo "Error: Failed to list commits between $GITHUB_PR_BASE and $GITHUB_PR_HEAD" >&2
        exit 1
    fi

    while IFS= read -r commit; do
        if [ "$first" = true ]; then
            commits_list="$commits_list\"$commit\""
            first=false
        else
            commits_list="$commits_list, \"$commit\""
        fi
    done < <(git rev-list "$GITHUB_PR_BASE".."$GITHUB_PR_HEAD")

    commits_list="$commits_list]"
    echo "$commits_list"
}


# Main logic with error handling
main() {
    # Validate that we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi

    case "$GITHUB_EVENT_NAME" in
        "push")
            list_push_commits
            ;;
        "pull_request")
            list_pr_commits
            ;;
        *)
            echo "Error: Unsupported event type: $GITHUB_EVENT_NAME" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main
