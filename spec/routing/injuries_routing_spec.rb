# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InjuriesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/injuries').to route_to('injuries#index')
    end

    it 'routes to #new' do
      expect(get: '/injuries/new').to route_to('injuries#new')
    end

    it 'routes to #show' do
      expect(get: '/injuries/1').to route_to('injuries#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/injuries/1/edit').to route_to('injuries#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/injuries').to route_to('injuries#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/injuries/1').to route_to('injuries#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/injuries/1').to route_to('injuries#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/injuries/1').to route_to('injuries#destroy', id: '1')
    end
  end
end
