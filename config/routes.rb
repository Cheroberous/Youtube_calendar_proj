Rails.application.routes.draw do
  devise_for :users
  get 'login/base'  # porta a app/views/login/base.html.erb
  get "/homepage", to: "homepage#cliente"

  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

