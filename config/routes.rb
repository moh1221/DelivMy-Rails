Rails.application.routes.draw do
  root "home#index"

  resources :password_resets, only: [:new, :create]
  get "password_resets/edit", to: "password_resets#edit", as: :edit_password_reset
  patch "password_resets", to: "password_resets#update"
  get "uploads/new", to: "uploads#new", as: :new_uploads
  post "uploads/new", to: "uploads#create", as: :uploads_new

  get "search", to: "search#index"
  get "search/:id", to: "search#show", as: :searchs

  get "profiles", to: "profiles#show", as: :profile
  patch "profiles", to: "profiles#update"

  get "signup", to: "users#new", as: :signup
  post "signup", to: "users#create"
  get "user", to: "users#show", as: :user
  patch "user", to: "users#update"
  get "users/new", to: "users#new"
  post "users", to: "users#create", as: :users

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :requests, only: [:new, :create, :index, :show, :destroy] do
    resources :items, only: :index
    resources :locations, only: :index
  end

  get "delivers/new", to: "delivers#new", as: :new_delivers
  post "delivers/new", to: "delivers#create"
  resources :delivers, only: [:index, :show]
end
