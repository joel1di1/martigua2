# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/sections/:section_id/events').to route_to('events#index', 'section_id' => ':section_id')
    end
  end
end
