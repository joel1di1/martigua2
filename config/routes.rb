# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
      resources :admin_users
      resources :calendars
      resources :championships
      resources :clubs
      resources :club_admin_roles
      resources :days
      resources :duty_tasks
      resources :enrolled_team_championships
      resources :groups
      resources :locations
      resources :matches
      resources :match_availabilities
      resources :match_selections
      resources :participations
      resources :scrapped_rankings
      resources :seasons
      resources :sections
      resources :section_user_invitations
      resources :selections
      resources :sms_notifications
      resources :teams
      resources :trainings
      resources :training_invitations
      resources :training_presences
      resources :users

      root to: "users#index"
    end
  resources :days

  resources :championships

  resources :sections, only: [:show] do
    resources :duty_tasks
    resources :scrapped_rankings, only: [:index]
    resources :section_user_invitations, path: 'user_invitations', only: [:new, :show, :create, :index]
    resources :trainings do
      member do
        get 'presence_validation'
        post 'invitations'
        post 'cancellation'
        delete 'uncancel'
      end
    end
    resources :users, path: 'members' do
      resources :trainings, only: [] do
        resources :training_presences, only: [:create]
        delete 'training_presences' => 'training_presences#destroy'
        post 'confirm_presence' => 'training_presences#confirm_presence'
      end
      match 'training_presences', via: [:get, :post]
      match 'match_availabilities', via: [:get, :post]
    end

    resources :participations_renewal, only: [:index, :create]

    resources :groups do
      post 'users' => 'groups#add_users', as: 'add_users'
      resources :users, only: [:destroy]
    end
    resources :matches do
      member do
        post :selection
        resources :selections, only: [:destroy]
      end
    end
    resources :championships do
      resources :matches
      resources :enrolled_team_championships, only: [:index, :create, :destroy]
    end
    resources :sms_notifications, only: [:new, :create]
    resources :day, only: [] do
      resources :selections, only: [:index]
    end
    resources :calendars, only: [:index, :create, :edit, :update]
    resources :days, only: [:create]
    resources :locations, only: [:create]
    resources :teams, only: [:create]
  end

  resources :club_admin_roles, only: [:index, :show]

  resources :teams, only: [:index, :show]

  resources :ping, only: :index, :constraints => { :format => :json }

  resources :clubs, only: [:index, :show] do
    resources :sections, only: [:index, :new, :create]
  end

  devise_for :users

  resources :users, only: [:show, :edit, :update] do
    member do
      match 'training_presences', via: [:get, :post]
      match 'match_availabilities', via: [:get, :post]
    end
  end

  root to: 'visitors#index'

  get 'switch_user', to: 'switch_user#set_current_user'
  get 'switch_user/remember_user', to: 'switch_user#remember_user'

  mount Starburst::Engine => "/starburst"

  match "*path", to: "application#catch_404", via: :all
end
