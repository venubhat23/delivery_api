Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/signup', to: 'authentication#signup'
      post '/login', to: 'authentication#login'
      post '/customer_login', to: 'authentication#customer_login'
      post '/regenerate_token', to: 'authentication#regenerate_token'
      
      # Categories routes
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      
      # Customers routes
      resources :customers, only: [:index, :show, :create] do
        member do
          post :update_location
          put :settings, action: :update_settings
        end
      end
      
      # Customer Address routes
      post '/customer_address', to: 'customer_addresses#create'
      get '/customer_address/:id', to: 'customer_addresses#show'
      put '/customer_address/:id', to: 'customer_addresses#update'
      patch '/customer_address/:id', to: 'customer_addresses#update'
      delete '/customer_address/:id', to: 'customer_addresses#destroy'
      get '/customer_addresses', to: 'customer_addresses#index'
      
      # Products routes
      resources :products do
        collection do
          get :low_stock
        end
      end
      
      # Orders routes (single-day orders)
      post '/place_order', to: 'orders#place_order'
      get '/orders', to: 'orders#index'
      
      # Subscriptions routes (multi-day subscriptions)
      resources :subscriptions, only: [:index, :create, :update, :destroy]
      
      # New APIs
      resources :advertisements, only: [:index]
      resources :invoices, only: [:index]
      get '/settings', to: 'settings#show'
      resources :vacations, only: [:index, :create]
      post '/refresh', to: 'refresh#create'
      
      # Delivery assignments routes
      resources :delivery_assignments, only: [:index, :show] do
        collection do
          get :today
          post :start_nearest
        end
        
        member do
          post :complete
          post :add_items
        end
        
        # Nested delivery items
        resources :delivery_items, only: [:index, :create], shallow: true
      end
      
      # Delivery schedules routes (for admin/delivery person management)
      resources :delivery_schedules, only: [:index, :show, :create, :update, :destroy]
      
      # Delivery items routes (for individual item operations)
      resources :delivery_items, only: [:show, :update, :destroy]
      
      # Bank details route
      get '/bank_details', to: 'bank_details#show'
      
      # Legacy delivery routes (keeping for backward compatibility)
      scope :deliveries do
        post '/start', to: 'deliveries#start'
        post '/:id/complete', to: 'deliveries#complete'
        get '/customers', to: 'deliveries#customers'
        get '/today_summary', to: 'deliveries#today_summary'
        
        # Catch-all for partial delivery URLs
        match '/:id/*path', to: 'deliveries#api_not_found', via: :all
        match '*path', to: 'deliveries#api_not_found', via: :all
      end
    end
    
    # Catch-all route for unmatched API v1 paths
    match 'v1/*path', to: 'application#api_not_found', via: :all
  end
  
  # Catch-all route for unmatched API paths
  match 'api/*path', to: 'application#api_not_found', via: :all
end