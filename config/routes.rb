Rails.application.routes.draw do
  devise_for :users

  root to: 'welcomes#index'
end
