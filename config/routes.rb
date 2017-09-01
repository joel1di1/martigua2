Rails.application.routes.draw do

  resources :days

  resources :championships

  resources :sections, only: [:show] do
    resources :section_user_invitations, path: 'user_invitations', only: [:new, :show, :create, :index]
    resources :trainings do
      member do
        post 'invitations'
      end
    end
    resources :users, path: 'members' do
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
  end

  resources :club_admin_roles, only: [:index, :show]

  resources :teams, only: [:index, :show]

  resources :ping, only: :index, :constraints => {:format => :json }

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

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'visitors#index'

  get 'switch_user', to: 'switch_user#set_current_user'
  get 'switch_user/remember_user', to: 'switch_user#remember_user'

  match "*path", to: "application#catch_404", via: :all
end
