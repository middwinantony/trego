Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#home'

  # Subscriptions
  resources :subscriptions, only: [:new, :create, :index]

  # Rides
  resources :rides, only: [:new, :create, :show, :index, :update]

  # Payments
  resources :payments, only: [:create] do
    member do
      post :refund
    end
  end

  # Stripe webhooks
  post '/webhooks/stripe', to: 'webhooks#stripe'

  # Complaints
  resources :complaints, only: [:index, :new, :create, :show]

  # KYC Documents
  resources :kyc_documents, only: [:index, :new, :create, :show]

  # Earnings (for drivers)
  resources :earnings, only: [:index]

  # Drivers
  resources :drivers, only: [:index, :show, :update] do
    member do
      post :update_location
    end
  end

  # Dashboard
  get "/dashboard", to: "pages#dashboard"

  # Admin namespace
  namespace :admin do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'

    resources :drivers, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end

    resources :vehicles, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end

    resources :rides, only: [:index, :show]
    resources :subscriptions, only: [:index, :show]
    resources :complaints, only: [:index, :show, :update]

    resources :kyc_documents, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end
  end
end
