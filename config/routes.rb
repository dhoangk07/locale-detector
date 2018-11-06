Rails.application.routes.draw do
  devise_for :users
  resources :repos do
    get :subscribe, on: :member
    get :unsubscribe, on: :member
  end
  root to: 'welcomes#index'
end
