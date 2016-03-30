Rails.application.routes.draw do

  get 'items/index'

  resources :password_resets

  get 'uploads/new' => 'uploads#new', as: :new_uploads
  post 'uploads/new' => 'uploads#create'

  # resource :uploads

  get '/search' => 'search#index'
  get '/search/:id'  => 'search#show', as: :searchs

  # resource :search

  get '/profiles' => 'profiles#show', as: :profile
  get 'profiles/new' => 'profiles#new'
  post 'profiles/new' => 'profiles#create'

  get 'signup' => 'users#new', as: :users
  post 'signup' => 'users#create'
  get '/user' => 'users#show'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  resources :users

  get '/requests/new' => 'requests#new'
  post '/requests' => 'requests#create'
  get '/requests' => 'requests#index'
  get '/requests/:id' => 'requests#show', as: :request
  delete '/requests/:id' => 'requests#destroy'


  resources :requests do
    resources :items
    resources :locations
  end

  get '/delivers/new' => 'delivers#new', as: :new_delivers
  post '/delivers/new' => 'delivers#create'
  get '/delivers' => 'delivers#index'
  get '/delivers/:id' => 'delivers#show', as: :deliver

  # resource :delivers

  root 'home#index'

end
