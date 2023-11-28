Rails.application.routes.draw do
    namespace :api do
        resources :users
        get '/users/autocomplete', to: 'users#autocomplete'
    end
end
