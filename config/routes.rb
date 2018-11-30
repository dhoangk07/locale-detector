require 'resque/server'

Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  resources :repos do
    post :subscribe, on: :member
    delete :unsubscribe, on: :member
    get :search, on: :collection
    get :stop_send_email_for_user_subscribed, on: :member
  end

  resque_web_constraint = lambda do |request|
    current_user = request.env['warden'].user
    current_user.present? && current_user.respond_to?(:is_admin?) && current_user.is_admin?
  end

  constraints resque_web_constraint do
    mount Resque::Server, at: '/resque'  
  end
  
  root to: "repos#index"
end

