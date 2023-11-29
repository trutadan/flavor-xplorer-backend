Rails.application.routes.draw do
    namespace :api do
        resources :users do
            collection do
                get 'autocomplete'
            end
        end

        post '/login', to: 'sessions#create'
        delete '/logout', to: 'sessions#destroy'
    end
end
