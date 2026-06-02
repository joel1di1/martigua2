# frozen_string_literal: true

require 'rails_helper'

describe 'ping' do
  it 'visit the home page' do
    visit 'ping'
    expect(page).to have_text 'hostname'
    expect(page).to have_text 'revision'
    expect(page).to have_text 'current_time'
  end
end
