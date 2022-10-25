Rails.application.routes.draw do   
  resources :affiliations
  resources :reviews
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
   get '/cliente/managerprofile' => 'cliente#visualize'

  get '/manager' => 'manager#index'

  get '/reviews' => 'review#index'
  # Defines the root path route ("/")
  # root "articles#index"
end
