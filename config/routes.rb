Rails.application.routes.draw do
  devise_for :users , controllers: {
    sessions: 'users/sessions',
    registrations: 'user/registration'
  }
 
  get 'login/base'  # porta a app/views/login/base.html.erb
  get "/homepage", to: "homepage#cliente"

  # root "/homepage#cliente"

  
  

  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

