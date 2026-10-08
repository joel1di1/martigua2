#!/usr/bin/env bash
# Moves issues on the project board (.github/workflows/agent-board.yml): one card per issue,
# its Status field being the column.
#
#   script/managed_agents/board.sh move <issue> <status>   # adds the issue to the board if needed
#   script/managed_agents/board.sh archive <issue>
#   script/managed_agents/board.sh deployed <sha>          # Merged cards whose PR is in <sha> -> Deployed
#
# Needs GH_TOKEN (classic, project scope), PROJECT_OWNER and PROJECT_NUMBER, and runs in the repo.
set -euo pipefail

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
project_id=$(gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq .id)
field=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --jq '.fields[] | select(.name == "Status")')

item_id() {
  gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "https://github.com/$repo/issues/$1" --format json --jq .id
}

set_status() {
  local option
  option=$(jq -r --arg name "$2" '.options[] | select(.name == $name) | .id' <<<"$field")
  if [ -z "$option" ]; then
    echo "no status '$2' on the board" >&2
    exit 1
  fi
  gh project item-edit --id "$1" --project-id "$project_id" --field-id "$(jq -r .id <<<"$field")" \
    --single-select-option-id "$option" >/dev/null
}

merge_commit() {
  # shellcheck disable=SC2016 # GraphQL variables, not shell ones.
  gh api graphql -F number="$1" -f owner="${repo%/*}" -f name="${repo#*/}" -f query='
    query($owner: String!, $name: String!, $number: Int!) {
      repository(owner: $owner, name: $name) {
        issue(number: $number) {
          closedByPullRequestsReferences(first: 10, includeClosedPrs: true) { nodes { mergeCommit { oid } } }
        }
      }
    }' --jq '[.data.repository.issue.closedByPullRequestsReferences.nodes[].mergeCommit.oid // empty][0] // empty'
}

case $1 in
  move)
    set_status "$(item_id "$2")" "$3"
    echo "#$2 -> $3"
    ;;
  archive)
    gh project item-archive "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --id "$(item_id "$2")" >/dev/null
    echo "#$2 archived"
    ;;
  deployed)
    gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --limit 1000 --format json \
      --jq '.items[] | select(.status == "Merged" and .content.type == "Issue") | "\(.id) \(.content.number)"' |
      while read -r id issue; do
        commit=$(merge_commit "$issue")
        # Closed as completed without a PR: nothing to wait for.
        if [ -z "$commit" ] ||
          [[ $(gh api "repos/$repo/compare/$commit...$2" --jq .status) =~ ^(ahead|identical)$ ]]; then
          set_status "$id" Deployed
          echo "#$issue -> Deployed"
        fi
      done
    ;;
  *)
    echo "usage: board.sh move <issue> <status> | archive <issue> | deployed <sha>" >&2
    exit 1
    ;;
esac
