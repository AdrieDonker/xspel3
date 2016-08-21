Rails.application.routes.draw do
  resources :turns
  resources :gamers
  resources :games
  resources :settings
  resources :boards
  resources :words_lists
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :letter_sets
end
