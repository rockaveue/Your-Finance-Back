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
                  }
      # resources :sessions, only: [:create, :destroy]
      # resources :registrations, only: [:create, :destroy]
      resources :users, except: :index do
        resources :transactions do
          collection do
            post :getDataByDate
            post :getDataByBetweenDate
          end
        end
        resources :categories do
          collection do
            post :getAmountByType
            post :getCategory
          end
        end
      end
      get 'defaultCategory', to: 'categories#defaultAllCategory'
    end
  end
end