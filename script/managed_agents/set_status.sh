#!/usr/bin/env bash
# Gives an issue or PR exactly one agent:* status label: removes the other agent:* labels
# and adds <label>. See the label list in config/managed_agents/setup.sh.
#
#   script/managed_agents/set_status.sh 1234 agent:queued
#
# Needs gh authenticated (GH_TOKEN) on the repository (GH_REPO, or the git remote).
set -euo pipefail

number=$1
label=$2

gh api "repos/{owner}/{repo}/issues/$number/labels" --jq '.[].name | select(startswith("agent:"))' |
  while read -r current; do
    if [ "$current" != "$label" ]; then
      gh api --method DELETE "repos/{owner}/{repo}/issues/$number/labels/$current" --silent
    fi
  done
gh api --method POST "repos/{owner}/{repo}/issues/$number/labels" -f "labels[]=$label" --silent
