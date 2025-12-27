Rails.application.routes.draw do
  devise_for :users, skip: [:registrations], controllers: {
    sessions: 'devise/sessions'
  }

  # Onboarding routes
  get '/onboarding/welcome', to: 'onboarding#welcome', as: :onboarding_welcome
  get '/onboarding/phone', to: 'onboarding#phone', as: :onboarding_phone
  post '/onboarding/send_code', to: 'onboarding#send_code', as: :onboarding_send_code
  get '/onboarding/verify_code', to: 'onboarding#verify_code', as: :onboarding_verify_code
  post '/onboarding/verify_code', to: 'onboarding#check_code'
  post '/onboarding/resend_code', to: 'onboarding#resend_code', as: :onboarding_resend_code
  get '/onboarding/profile', to: 'onboarding#profile', as: :onboarding_profile
  post '/onboarding/profile', to: 'onboarding#create_profile', as: :onboarding_create_profile
  get '/onboarding/permissions', to: 'onboarding#permissions', as: :onboarding_permissions
  post '/onboarding/permissions', to: 'onboarding#save_permissions', as: :onboarding_save_permissions
  get '/onboarding/documents', to: 'onboarding#documents', as: :onboarding_documents
  get '/onboarding/complete', to: 'onboarding#complete', as: :onboarding_complete

  get "up" => "rails/health#show", as: :rails_health_check
  root 'onboarding#welcome'

  # Subscriptions
  resources :subscriptions, only: [:new, :create, :index]

  # Rides
  resources :rides, only: [:new, :create, :show, :index, :update] do
    collection do
      get :search
    end
    member do
      post :accept
      get :matching
      post :rate
      get :receipt
    end
  end

  # Saved Locations
  resources :saved_locations, only: [:index, :create, :destroy]

  # Vehicles
  resources :vehicles

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
