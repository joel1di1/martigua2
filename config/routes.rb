Rails.application.routes.draw do

  resources :sections, only: [:show] do
    resources :users, path: 'members', only: [:index, :show, :edit, :update]
    resources :trainings, only: [:show, :index, :create, :new] do
      member do
        post 'invitations'
      end
    end
    resources :section_user_invitations, path: 'user_invitations', only: [:new, :show, :create, :index]
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
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'visitors#index'
end
