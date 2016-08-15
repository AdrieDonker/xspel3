Rails.application.routes.draw do
  resources :letter_sets
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
