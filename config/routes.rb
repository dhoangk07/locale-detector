require 'resque/server'

Rails.application.routes.draw do
  devise_for :users
  resources :repos do
    post :subscribe, on: :member
    delete :unsubscribe, on: :member
    post :search, on: :collection
  end

  root to: "repos#index"
  mount Resque::Server, at: '/resque'  
end
