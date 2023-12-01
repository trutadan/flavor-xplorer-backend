Rails.application.routes.draw do
    namespace :api do
        resources :users do
            collection do
                get 'autocomplete'
            end

            resource :account, controller: 'user_accounts', only: [:show, :update, :destroy]
            collection do
              get 'accounts' => 'user_accounts#index'
            end
        end

        post '/login', to: 'sessions#create'
        delete '/logout', to: 'sessions#destroy'
    end
end
