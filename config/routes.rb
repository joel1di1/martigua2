Rails.application.routes.draw do

  resources :club_admin_roles

  resources :teams

  resources :ping, only: :index, :constraints => {:format => :json }

  resources :clubs

  devise_for :users

  resources :users


  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'visitors#index'
end
