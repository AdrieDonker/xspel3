Rails.application.routes.draw do
  resources :settings, :boards, :words_lists, :letter_sets
  # resources :turns
  resources :games do
   member do
    get 'play'
   end
   resources :gamers do
    get 'invite'
   end
   resources :turns do
    get 'pass'
    get 'swap'
    get 'play'
    get 'blank'
   end
  end
  devise_for :users
  resources :users
  root to: 'visitors#index'
end
