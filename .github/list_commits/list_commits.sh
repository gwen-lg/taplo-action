#!/bin/bash

set -euo pipefail

# Function to list commits for pull_request events
list_pr_commits() {
    for commit in $(git rev-list ${GITHUB_PR_BASE}..${GITHUB_PR_HEAD}); do
    if [[ -v commit_list ]]
    then
        commit_list="$commit_list, \"$commit\""
    else
        commit_list="[ \"$commit\""
    fi
    done
    commit_list="$commit_list ]"
    echo "commits=${commit_list}" >> "$GITHUB_OUTPUT"
}

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
