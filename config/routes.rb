Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "photos#index"
  
  devise_for :users

  resources :comments
  resources :follow_requests
  resources :likes
  resources :photos
end
