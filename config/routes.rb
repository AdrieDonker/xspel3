Rails.application.routes.draw do
  resources :settings, :boards, :words_lists, :letter_sets
  resources :turns
  resources :games do
   member do
    get 'play'
   end
  end
  devise_for :users
  resources :users
  root to: 'visitors#index'
end
