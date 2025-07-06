Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/signup', to: 'authentication#signup'
      post '/login', to: 'authentication#login'
      
      # Categories routes
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      
      # Customers routes
      resources :customers, only: [:index, :show, :create] do
        member do
          post :update_location
          put :settings, action: :update_settings
        end
      end
      
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
      
      # Legacy delivery routes (keeping for backward compatibility)
      scope :deliveries do
        post '/start', to: 'deliveries#start'
        post '/:id/complete', to: 'deliveries#complete'
        get '/customers', to: 'deliveries#customers'
        get '/today_summary', to: 'deliveries#today_summary'
      end
    end
  end
end