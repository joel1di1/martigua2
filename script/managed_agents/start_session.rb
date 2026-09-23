#!/usr/bin/env ruby
# frozen_string_literal: true

# Starts a Managed Agents session for a GitHub issue and exits; the agent runs on Anthropic's side.
#
#   script/managed_agents/start_session.rb 1234
#   script/managed_agents/start_session.rb --message "Run the setup script and bin/rspec, report, don't touch GitHub"
#
# Needs ANTHROPIC_API_KEY, AGENT_GITHUB_TOKEN, AGENT_ID, ENVIRONMENT_ID, VAULT_ID (see config/managed_agents/setup.sh)
# and the anthropic gem (gem install anthropic).

require 'anthropic'

REPO_URL = 'https://github.com/joel1di1/martigua2'
BUDGET_CENTS = '1500'

if ARGV[0] == '--message'
  text = ARGV[1]
  title = 'martigua2 ad-hoc run'
else
  issue = Integer(ARGV[0])
  text = "Work on issue ##{issue}"
  title = "martigua2 issue ##{issue}"
end
abort 'usage: start_session.rb <issue-number> | --message "<text>"' if text.to_s.empty?

client = Anthropic::Client.new
session = client.beta.sessions.create(
  agent: ENV.fetch('AGENT_ID'),
  environment_id: ENV.fetch('ENVIRONMENT_ID'),
  vault_ids: [ENV.fetch('VAULT_ID')],
  title:,
  resources: [
    {
      type: 'github_repository',
      url: REPO_URL,
      mount_path: '/workspace/martigua2',
      authorization_token: ENV.fetch('AGENT_GITHUB_TOKEN'),
      checkout: { type: 'branch', name: 'main' }
    }
  ],
  budget: { type: 'limit', max_list_cost: { amount: BUDGET_CENTS, currency: 'USD' } },
  initial_events: [{ type: 'user.message', content: [{ type: 'text', text: }] }]
)

puts "Session #{session.id} (#{session.status})"
puts "Watch: https://platform.claude.com/workspaces/default/sessions/#{session.id}"
