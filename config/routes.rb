Rails.application.routes.draw do
    namespace :api do
        post '/login', to: 'sessions#create'
        delete '/logout', to: 'sessions#destroy'

        resources :users do
            collection do
                get 'autocomplete'
            end

            resource :account, controller: 'user_accounts', only: [:show, :update, :destroy]
            collection do
              get 'accounts' => 'user_accounts#index'
            end

            member do
                get 'followers', to: 'relationships#followers'
                get 'following', to: 'relationships#following'
            end
        end

        post '/relationships/follow', to: 'relationships#follow'
        post '/relationships/unfollow', to: 'relationships#unfollow'

        resources :posts, only: [:index, :create, :show, :update, :destroy] do
            collection do
                get :feed
                get :explore
                get 'bookmarks', to: 'bookmarks#index'
            end

            member do
                post 'bookmark', to: 'bookmarks#bookmark'
                delete 'unbookmark', to: 'bookmarks#unbookmark'
            end
        end
    end
end
