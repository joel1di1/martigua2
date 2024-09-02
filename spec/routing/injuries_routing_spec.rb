# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InjuriesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/sections/1-Homme%20+16/members/6/injuries').to route_to('injuries#index', section_id: '1-Homme +16', user_id: '6')
    end

    it 'routes to #new' do
      expect(get: '/sections/1-Homme%20+16/members/6/injuries/new').to route_to('injuries#new', section_id: '1-Homme +16', user_id: '6')
    end

    it 'routes to #create' do
      expect(post: '/sections/1-Homme%20+16/members/6/injuries').to route_to('injuries#create', section_id: '1-Homme +16', user_id: '6')
    end

    it 'routes to #destroy' do
      expect(delete: '/sections/1-Homme%20+16/members/6/injuries/1').to route_to('injuries#destroy', id: '1', section_id: '1-Homme +16', user_id: '6')
    end
  end
end
