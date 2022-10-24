Rails.application.routes.draw do
  root 'pages#home'
  
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/profile' => 'profile#index'
  get '/profile/nameandrole' => 'profile#nameandrole'

  get '/cliente' => 'cliente#search'
  get '/cliente/function' => 'cliente#function'
  get '/manager' => 'manager#index'
  # Defines the root path route ("/")
  # root "articles#index"
end
