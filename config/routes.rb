Rails.application.routes.draw do
  get 'challenge_view/index'
  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "landing#index"

  # Auth
  get 'auth', to: 'auth#index'
  get 'auth/:provider/callback', to: 'sessions#create' 
  get '/auth/google_oauth2', as: :sign_in
  get '/auth/failure' => 'sessions#failure'
  get '/sign_out', to: 'sessions#destroy', as: :sign_out 

  # Dashboard
  get 'dashboard', to: 'dashboard#index'

  # Challenges
  get 'challenge_creator', to: 'challenge_creator#index'

  get 'challenge_create', to: 'challenge_view#create',
    constraints: lambda { |req| # we can only create if we have parameters
      req.params[:query].present? && req.params[:difficulty].present? 
    }
  get 'challenges/:challenge_id', to: 'challenge_view#play', as: 'challenges'

  # challenge functionality
  post 'update_order', to: 'challenge_view#update_order'
end