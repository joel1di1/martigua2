# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscussionsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/sections/:section_id/discussions').to route_to('discussions#index', 'section_id' => ':section_id')
    end

    it 'routes to #new' do
      expect(get: '/sections/:section_id/discussions/new').to route_to('discussions#new', 'section_id' => ':section_id')
    end

    it 'routes to #show' do
      expect(get: '/sections/:section_id/discussions/1').to route_to('discussions#show', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/sections/:section_id/discussions/1/edit').to route_to('discussions#edit', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/sections/:section_id/discussions').to route_to('discussions#create', 'section_id' => ':section_id')
    end

    it 'routes to #update via PUT' do
      expect(put: '/sections/:section_id/discussions/1').to route_to('discussions#update', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/sections/:section_id/discussions/1').to route_to('discussions#update', 'section_id' => ':section_id', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/sections/:section_id/discussions/1').to route_to('discussions#destroy', 'section_id' => ':section_id', id: '1')
    end
  end
end
