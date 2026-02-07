Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  root "home#index"
  resources :guests, only: [:create]
  resources :events do
    resources :participants, only: [:create, :destroy, :edit, :update]
    resources :groupings, only: [:create]
  end

  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
