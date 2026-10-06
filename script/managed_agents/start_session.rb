#!/usr/bin/env ruby
# frozen_string_literal: true

# Starts a Managed Agents session on the self-hosted environment and exits. The session
# waits in the queue until .github/workflows/agent-sandbox.yml claims it and runs its tools.
#
#   script/managed_agents/start_session.rb 1234            # work on issue #1234
#   script/managed_agents/start_session.rb --pr 1250       # address feedback on PR #1250
#   script/managed_agents/start_session.rb --message "Run bin/rspec, report, don't touch GitHub"
#
# Needs ANTHROPIC_API_KEY, AGENT_ID, ENVIRONMENT_ID, VAULT_ID (see config/managed_agents/setup.sh),
# WORKSPACE_ID for the Console link, and the anthropic gem (gem install anthropic). Anthropic does
# not mount the repository on self-hosted environments: the sandbox runner checks it out itself.

require 'anthropic'

BUDGET_CENTS = '1500'

case ARGV[0]
when '--message'
  text = ARGV[1]
  title = 'martigua2 ad-hoc run'
  metadata = {}
when '--pr'
  pr = Integer(ARGV[1])
  text = "Address the feedback on PR ##{pr}"
  title = "martigua2 PR ##{pr}"
  metadata = { github_pr: pr.to_s }
else
  issue = Integer(ARGV[0])
  text = "Work on issue ##{issue}"
  title = "martigua2 issue ##{issue}"
  metadata = { github_issue: issue.to_s }
end
abort 'usage: start_session.rb <issue-number> | --pr <pr-number> | --message "<text>"' if text.to_s.empty?

client = Anthropic::Client.new
session = client.beta.sessions.create(
  agent: ENV.fetch('AGENT_ID'),
  environment_id: ENV.fetch('ENVIRONMENT_ID'),
  vault_ids: [ENV.fetch('VAULT_ID')],
  title:,
  metadata:,
  budget: { type: 'limit', max_list_cost: { amount: BUDGET_CENTS, currency: 'USD' } },
  initial_events: [{ type: 'user.message', content: [{ type: 'text', text: }] }]
)

puts "Session #{session.id} (#{session.status})"
# The session does not say which workspace it is in, and the Console has no link without one.
puts "Watch: https://platform.claude.com/workspaces/#{ENV.fetch('WORKSPACE_ID', 'default')}/sessions/#{session.id}"
