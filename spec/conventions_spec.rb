# frozen_string_literal: true

require 'rails_helper'

# P12 (docs/code_quality_todo.md): the project convention is Slim templates.
# The HAML migration was completed once and then silently regressed when new
# mailer views were added, so guard the convention instead of re-running the
# migration.
RSpec.describe 'Template engine convention' do # rubocop:disable RSpec/DescribeClass
  it 'has no HAML templates left' do
    haml_views = Rails.root.glob('app/views/**/*.haml').map { |path| path.relative_path_from(Rails.root).to_s }

    expect(haml_views).to be_empty,
                          "Project convention is Slim (see CLAUDE.md). Convert to .slim:\n  #{haml_views.join("\n  ")}"
  end
end
