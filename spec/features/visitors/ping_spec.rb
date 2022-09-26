# frozen_string_literal: true

require 'rails_helper'

describe 'ping' do
  it 'visit the home page' do
    visit 'ping'
    expect(page).to have_content 'hostname'
    expect(page).to have_content 'revision'
    expect(page).to have_content 'current_time'
  end
end
