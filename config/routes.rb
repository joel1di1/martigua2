Rails.application.routes.draw do

  resources :sections, only: [:index, :show] do
    resources :users, path: 'members', only: [:index, :show]
    resources :trainings, only: [:index, :create, :new]
    resources :section_user_invitations, path: 'user_invitations', only: [:new, :show, :create, :index]
  end

  resources :club_admin_roles, only: [:index, :show]

  resources :teams, only: [:index, :show]

  resources :ping, only: :index, :constraints => {:format => :json }

  resources :clubs, only: [:index, :show]

  devise_for :users

  resources :users


  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'visitors#index'
end
