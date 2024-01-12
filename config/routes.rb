Rails.application.routes.draw do
    namespace :api do
        post '/login', to: 'sessions#create'
        delete '/logout', to: 'sessions#destroy'
        get '/users/:id/posts', to: 'posts#user_posts'

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
                get :all
                get :feed
                get :explore

                get 'bookmarks', to: 'bookmarks#index'
                get 'bookmarks/all', to: 'bookmarks#all'

                get 'ratings', to: 'ratings#all'

                get 'comments', to: 'comments#all'
                get 'comments/:id', to: 'comments#show'
            end

            member do
                post 'bookmark', to: 'bookmarks#bookmark'
                delete 'unbookmark', to: 'bookmarks#unbookmark'
                post 'rate', to: 'ratings#rate'
            end

            resources :ratings, only: [:index]

            resources :comments, only: [:index, :create, :update, :destroy] do
                member do
                    get 'replies', to: 'comments#replies'
                    post 'replies', to: 'comments#reply'
                end
            end
        end
    end
end
