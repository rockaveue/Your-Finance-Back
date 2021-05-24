Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      resources :sessions, only: [:create, :destroy]
      resources :registrations, only: [:create, :destroy]
      resources :users, except: :index do
        resources :transactions do
          # users/{id}/transactions/{id}/{category_id}
          get "category", to: "categories#show"
        end
        resources :user_categories do
          # users/{id}/user_categories/{id}/{category_id}
          # get "/category", to: "category#show"
        end
        # get "/transactions", to: "transactions#index"
      end
    end
  end
end
