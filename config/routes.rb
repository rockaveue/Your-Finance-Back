Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      resources :users do
        resources :transactions do
          resources :categories
        end
        resources :user_categories do
          resources :categories
        end
      end
    end
  end
end
