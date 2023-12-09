class Api::UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy]
    before_action :require_authentication, except: [:create]

    # GET api/users
    def index
        # Only admins can view all users
        authorize User

        # Return all users in descending order of creation date
        @users = User.all.order(created_at: :desc).paginate(page: params[:page], per_page: 25)
        @total_pages = @users.total_pages

        render json: {
            # Only return the id, username, email, and role of each user
            users: @users.as_json(only: role_based_attributes),
            total_pages: @total_pages
        }, status: :ok
    end
  
    # GET api/users/autocomplete
    def autocomplete
        if params[:query]
            # Search for users whose usernames contain the query string
            query = params[:query]

            # Only return the id and username of the first 5 users
            @users = User.where("username ILIKE ?", "%#{query}%").order(:username).limit(5)
            render json: @users.as_json(only: [:id, :username]), status: :ok
        else
            render json: { errors: "Missing query parameter" }, status: :bad_request
        end
    end
  
    # GET api/users/1
    def show
        # Only admins can view all users
        authorize @user

        # If the user is an admin, they can view all users details, including their roles
        # If the user is regular, he can only view his own details
        render json: @user.as_json(only: role_based_attributes), status: :ok
    end

    # POST api/users
    def create
        # Anyone can create a user
        @user = User.new(user_register_params.slice(:username, :email, :password, :password_confirmation))
        @user_account = UserAccount.new(user_register_params.slice(:first_name, :last_name, :gender))
    
        ActiveRecord::Base.transaction do
            if @user.save
                # Set the user_id for the UserAccount before saving
                @user_account.user_id = @user.id
    
                # Save the user account
                if @user_account.save
                    render json: { message: "User has been successfully created" }, status: :created
                else
                    render json: { errors: @user_account.errors }, status: :unprocessable_entity
                    # Rollback the transaction if user account save fails
                    raise ActiveRecord::Rollback
                end
            else
                render json: { errors: @user.errors }, status: :unprocessable_entity
                # Rollback the transaction if user save fails
                raise ActiveRecord::Rollback
            end
        end
    end
  
    # PATCH/PUT api/users/1
    def update
        # Only admins can update all users
        authorize @user

        # Admins can update any user's details
        # Regular users can only update their own details, except for their role
        if @user.update(current_user&.admin? ? user_params_with_role : user_params)
            render json: @user.as_json(only: role_based_attributes), status: :ok
        else
            render json: {errors: @user.errors }, status: :unprocessable_entity
        end
    end
  
    # DELETE api/users/1
    def destroy
        # Only admins can delete all users
        authorize @user

        @user.destroy
        render json: { message: 'User has been deleted' }, status: :ok
    end
  
    private
        # Only allow a trusted register parameter "white list" through
        def user_register_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name, :gender)
        end

        def user_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation)
        end

        def user_params_with_role
            params.require(:user).permit(:username, :email, :password, :password_confirmation, :role)
        end

        # Returns the attributes that should be returned in the JSON response, based on the user's role
        def role_based_attributes
            if current_user.admin?
                [:id, :username, :email, :role]
            else
                [:id, :username, :email]
            end
        end

        # Use callbacks to share common setup or constraints between actions
        def set_user
            @user = User.find(params[:id])
            render_not_found("User not found") unless @user
        end
end
