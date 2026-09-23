#!/usr/bin/env bash
# One-time creation of the Managed Agents resources for the issue pipeline.
# Needs: ant (brew install anthropics/tap/ant) authenticated with your platform account,
# gh authenticated on joel1di1/martigua2, and AGENT_GITHUB_TOKEN set to a fine-grained PAT
# (this repo only; Contents, Issues, Pull requests: read & write).
#
# To change a prompt later, don't rerun this: edit the YAML, then
#   ant beta:agents update --agent-id <id> --version <current> < config/managed_agents/<file>.agent.yaml
set -euo pipefail
cd "$(dirname "$0")"

: "${AGENT_GITHUB_TOKEN:?export AGENT_GITHUB_TOKEN=<fine-grained PAT> first}"

ENVIRONMENT_ID=$(ant beta:environments create < martigua.environment.yaml --transform id -r)
ARCHITECT_ID=$(ant beta:agents create < architect.agent.yaml --transform id -r)
DEVELOPER_ID=$(ant beta:agents create < developer.agent.yaml --transform id -r)
REVIEWER_ID=$(ant beta:agents create < reviewer.agent.yaml --transform id -r)
AGENT_ID=$(ant beta:agents create < issue-lead.agent.yaml \
  --multiagent "{type: coordinator, agents: [$ARCHITECT_ID, $DEVELOPER_ID, $REVIEWER_ID]}" \
  --transform id -r)

VAULT_ID=$(ant beta:vaults create --display-name "martigua2 agents" --transform id -r)
ant beta:vaults:credentials create --vault-id "$VAULT_ID" --transform id -r <<YAML
display_name: GitHub MCP (martigua2 PAT)
auth:
  type: static_bearer
  mcp_server_url: https://api.githubcopilot.com/mcp/
  token: $AGENT_GITHUB_TOKEN
YAML

gh label create needs-answers --color d93f0b --description "Agent asked questions" --force
gh label create refined --color 0e8a16 --description "Agent refined the issue, waiting for human review" --force
gh label create good-to-dev --color 1d76db --description "Human approved the refined issue" --force
gh label create agent-working --color fbca04 --description "An agent session is running" --force
gh label create to-review --color 5319e7 --description "Agent opened a PR, waiting for human review" --force

gh variable set AGENT_ID --body "$AGENT_ID"
gh variable set ENVIRONMENT_ID --body "$ENVIRONMENT_ID"
gh variable set VAULT_ID --body "$VAULT_ID"
gh secret set AGENT_GITHUB_TOKEN --body "$AGENT_GITHUB_TOKEN"
echo "Now run: gh secret set ANTHROPIC_API_KEY   (paste your platform API key)"

cat <<EOF

export AGENT_ID=$AGENT_ID
export ENVIRONMENT_ID=$ENVIRONMENT_ID
export VAULT_ID=$VAULT_ID
# architect=$ARCHITECT_ID developer=$DEVELOPER_ID reviewer=$REVIEWER_ID
EOF
