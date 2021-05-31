Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      devise_for :users,
                  path: 'users',
                  path_names: {
                    sign_in: 'login',
                    sign_out: 'logout',
                    registration: 'signup'
                  },
                  controllers: {
                    sessions: 'api/v1/users/sessions',
                    registrations: 'api/v1/users/registrations',
                    confirmations: 'api/v1/confirmations'
                  }
      # resources :sessions, only: [:create, :destroy]
      # resources :registrations, only: [:create, :destroy]
      resources :users, except: :index do
        resources :transactions do
          # users/{id}/transactions/{id}/{category_id}
          get "category", to: "categories#transactionCategory"
        end
        # get "user_categories", to: "user_categories#index"
        resources :categories
        post "categories_by_type", to: "categories#getCategoryByType"
        post "get_type_amount_by_date", to: "categories#getAmountByType"
        post "get_data_by_date", to: "transactions#getDataByDate"
        post "get_data_by_between_date", to: "transactions#getDataByBetweenDate"
        # get "/transactions", to: "transactions#index"
      end
      # Default Category авах route
      get "default_category", to: "categories#defaultAllCategory"
    end
  end
end
