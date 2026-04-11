Rails.application.routes.draw do
  root "home#index"

  resources :pets, only: [:new, :create, :show] do
    member do
      post :feed
      post :play
      post :sleep_action
      post :clean
      post :discipline
      post :medicine
      post :tick
    end
  end
end