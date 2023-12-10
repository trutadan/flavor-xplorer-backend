class Api::RelationshipsController < ApplicationController
    before_action :set_user, only: [:followers, :following]
    before_action :set_followed_user, only: [:follow, :unfollow]
    before_action :require_authentication
    
    # GET api/users/:id/followers
    def followers
        authorize @user, :followers?

        followers = @user.followers.paginate(page: params[:page], per_page: 10) 
    
        render json: followers.as_json(only: user_params), status: :ok
    end
  
    # GET api/users/:id/following
    def following
        authorize @user, :following?

        following = @user.following.paginate(page: params[:page], per_page: 10) 
    
        render json: following.as_json(only: user_params), status: :ok
    end

    # POST api/relationships/follow
    def follow
        begin
            current_user.follow(@followed_user)
            render json: { message: "User followed successfully" }, status: :created
        rescue ArgumentError => error
            render json: { errors: error.message }, status: :unprocessable_entity
        end
    end

    # POST api/relationships/unfollow
    def unfollow
        begin
            current_user.unfollow(@followed_user)
            render json: { message: "User unfollowed successfully" }, status: :ok
        rescue ArgumentError => error
            render json: { errors: error.message }, status: :unprocessable_entity
        end
    end

    private 
        # Only allow a trusted parameter "white list" through
        def user_params
            [:id, :username]
        end

        # Use callbacks to share common setup or constraints between actions
        def set_user
            @user = User.find(params[:id])
            render_not_found("User not found") unless @user
        end

        def set_followed_user
            @followed_user = User.find(params[:followed_id])
            render_not_found("User not found") unless @followed_user
        end
end
