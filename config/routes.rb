Rails.application.routes.draw do
    namespace :api do
        resources :users
        get '/users/autocomplete', to: 'users#autocomplete'

        post '/login', to: 'sessions#create'
        delete '/logout', to: 'sessions#destroy'
    end
end
