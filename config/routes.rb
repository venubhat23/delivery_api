Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/signup', to: 'users#create'
      post '/login', to: 'authentication#login'
      
      # Customers routes
      resources :customers, only: [:index, :show, :create] do
        member do
          post :update_location
        end
      end
      

      # Products routes
      resources :products
      
      # Delivery routes - legacy endpoints
        post '/start', to: 'deliveries#start'
        post '/:id/complete', to: 'deliveries#complete'
        get '/customers', to: 'deliveries#customers'
      
      # Delivery schedules routes
      resources :delivery_schedules
      
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
      
      # Delivery items routes (for individual item operations)
      resources :delivery_items, only: [:show, :update, :destroy]
    end
  end
end