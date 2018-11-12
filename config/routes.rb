Rails.application.routes.draw do
  devise_for :users
  resources :repos do
    post :subscribe, on: :member
    delete :unsubscribe, on: :member
  end
  root to: "repos#index"
end
