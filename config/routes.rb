Rails.application.routes.draw do
  devise_for :users
  resources :repos

  root to: 'welcomes#index'
end
