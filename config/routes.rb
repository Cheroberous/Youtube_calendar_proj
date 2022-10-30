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
  get '/manager/affiliazioni' => 'manager#affiliazioni'
  get '/manager/aziende' => 'manager#aziende'
  get '/manager/singleone' => 'manager#singleone'
  get '/manager/events' => 'manager#events' 

  get '/azienda' => 'azienda#index'
  get '/azienda/affiliazioni' => 'azienda#affiliazioni'
  
  get '/affiliations/accept' => 'affiliation#accept'


  get '/utility/annulla' => 'utility#annulla'
  
  get '/reviews' => 'review#index'
  # Defines the root path route ("/")
  # root "articles#index"
  get "calendar/createCalendar" , to: "calendar#create"
  get "calendar/updateCalendar" , to: "calendar#update"
  get "calendar/deleteCalendar" , to: "calendar#delete"

  get "calendar/createEvent" , to: "calendar#createEvent"
  post "calendar/createEventConfirm" , to: "calendar#createEventConfirm"
  get "calendar/createEventConfirm" , to: "calendar#createEventConfirm"
  get "calendar/listEvent" , to: "calendar#listEvent"
  get "calendar/deleteEvent" , to: "calendar#deleteEvent"

  get "/event", to: "calendar#editEvent"
  patch "/event", to: "calendar#reviewEvent"

  get "/YTProva", to: "youtube#youtubeListProva"
  get "/upload", to: "youtube#upload"
  get "/caricati", to: "youtube#videoCaricati"
  
  get "/videocaricati", to: "videos#index"

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#fail'
  post '/videos/get_upload_token', to: 'videos#get_upload_token', as: :get_upload_token
  get '/videos/get_video_uid', to: 'videos#get_video_uid', as: :get_video_uid

end
