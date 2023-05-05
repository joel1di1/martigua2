# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChannelsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/sections/:section_id/channels').to route_to('channels#index', 'section_id' => ':section_id')
    end

    it 'routes to #new' do
      expect(get: '/sections/:section_id/channels/new').to route_to('channels#new', 'section_id' => ':section_id')
    end

    it 'routes to #show' do
      expect(get: '/sections/:section_id/channels/1').to route_to('channels#show', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/sections/:section_id/channels/1/edit').to route_to('channels#edit', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/sections/:section_id/channels').to route_to('channels#create', 'section_id' => ':section_id')
    end

    it 'routes to #update via PUT' do
      expect(put: '/sections/:section_id/channels/1').to route_to('channels#update', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/sections/:section_id/channels/1').to route_to('channels#update', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/sections/:section_id/channels/1').to route_to('channels#destroy', 'section_id' => ':section_id', id: '1')
    end
  end
end
