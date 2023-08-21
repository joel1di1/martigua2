# frozen_string_literal: true

require 'sidekiq/web'

# rubocop:disable Metrics/BlockLength
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
    resources :seasons
    resources :sections
    resources :section_user_invitations
    resources :selections
    resources :teams
    resources :trainings
    resources :training_invitations
    resources :training_presences
    resources :users

    root to: 'users#index'
  end
  resources :days

  resources :championships

  resources :sections, only: %i[show] do
    resources :duty_tasks
    resources :section_user_invitations, path: 'user_invitations', only: %i[new show create index]
    resources :trainings do
      resources :users, only: [] do
        get 'training_presence' => 'training_presences#show'
      end
      member do
        get 'presence_validation'
        post 'invitations'
        post 'cancellation'
        delete 'uncancel'
      end
    end
    resources :users, path: 'members' do
      resources :trainings, only: [] do
        resources :training_presences, only: %i[create show]
        delete 'training_presences' => 'training_presences#destroy'
        post 'confirm_presence' => 'training_presences#confirm_presence'
      end
      match 'training_presences', via: %i[get post]
      match 'match_availabilities', via: %i[get post]
    end

    resources :participations_renewal, only: %i[index create]

    resources :groups do
      post 'users' => 'groups#add_users', as: 'add_users'
      resources :users, only: [:destroy]
    end
    resources :matches do
      member do
        post :selection
        resources :selections, only: [:destroy]
        post 'invitations'
      end
    end
    resources :championships do
      resources :matches
      resources :enrolled_team_championships, only: %i[index create destroy]
      resources :burns, only: %i[index create destroy]
    end
    resources :day, only: [] do
      resources :selections, only: [:index]
    end
    resources :calendars, only: %i[index create edit update]
    resources :days, only: [:create]
    resources :locations, only: [:create]
    resources :teams, only: %i[create show delete new]
    resources :channels do
      resources :messages, only: %i[create destroy]
    end

    patch 'player_ffhb_association'
    delete 'dissociate_player'
  end

  resources :club_admin_roles, only: %i[index show]

  resources :teams, only: %i[index show]

  resources :clubs, only: %i[index show] do
    resources :sections, only: %i[index new create destroy edit update]
  end

  devise_for :users

  resources :users, only: %i[show edit update] do
    member do
      match 'training_presences', via: %i[get post]
      match 'match_availabilities', via: %i[get post]
    end
  end

  resources :messages, only: [] do
    collection do
      post 'mark_as_read'
    end
  end

  resources :webpush_subscriptions, only: [:create], constraints: { format: :json }

  authenticate :user, ->(u) { u.super_admin? } do
    mount Sidekiq::Web => 'sidekiq'
  end

  root to: 'visitors#index'

  get 'switch_user', to: 'switch_user#set_current_user'
  get 'switch_user/remember_user', to: 'switch_user#remember_user'
  get '.well-known/acme-challenge/4k3hP8fSRgCKf0inS8qYK9LYs8sU10ZMfSiYs8-Mcxg' => 'visitors#letsencrypt'
  get '.well-known/acme-challenge/DNyCHVFZJQpss-fIqj5vX317OwOjUfwRklgsSJMAJXo-Mcxg' => 'visitors#letsencrypt'
end
# rubocop:enable Metrics/BlockLength
