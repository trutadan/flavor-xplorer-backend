class Api::UsersController < ApplicationController
    # GET api/users
    def index
        authorize User

        # If the user is an admin, they can view all users
        @users = User.all.order(created_at: :desc).paginate(page: params[:page], per_page: 25)
        @total_pages = @users.total_pages

        render json: {
            # Only return the id, username, email, and role of each user
            users: JSON.parse(@users.to_json(only: role_based_attributes)),
            total_pages: @total_pages
        }
    end
  
    # GET api/users/autocomplete
    def autocomplete
        if params[:query]
            query = params[:query]

            # Search for users whose usernames contain the query string
            # Only return the id and username of the first 5 users
            @users = User.where("username ILIKE ?", "%#{query}%").order(:username).limit(5)
            render json: JSON.parse(@users.to_json(only: [:id, :username]))
        end
    end
  
    # GET api/users/1
    def show
        @user = User.find(params[:id])

        if @user
            authorize @user

            # If the user is an admin, they can view all users details, including their roles
            # If the user is regular, he can only view his own details
            render json: JSON.parse(@user.to_json(only: role_based_attributes)) 
        else
            render_not_found("User not found.")
        end
    end
  
    # POST api/users
    def create
        # Anyone can create a user
        @user = User.new(user_params)

        if @user.save
            create_user_account(user_account_params, @user.id)
            render json: @user, status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end
  
    # PATCH/PUT api/users/1
    def update
        @user = User.find(params[:id])

        if @user 
            authorize @user

            # Admins can update any user's details
            # Regular users can only update their own details, except for their role
            if @user.update(current_user&.admin? ? user_params_with_role : user_params)
                render json: @user
            else
                render json: @user.errors, status: :unprocessable_entity
            end
        else
            render_not_found("User not found.")
        end
    end
  
    # DELETE api/users/1
    def destroy
        @user = User.find(params[:id])
    
        if @user
            authorize @user

            # Only admins can delete users
            @user.destroy
            render json: { message: 'User has been deleted.' }, status: :ok
        else
            render_not_found("User not found.")
        end
    end
  
    private
        def user_account_params
            params.require(:user).permit(:first_name, :last_name, :gender)
        end

        def user_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation)
        end

        def user_params_with_role
            params.require(:user).permit(:username, :email, :password, :password_confirmation, :role)
        end

        def role_based_attributes
            if current_user.admin?
                # Admins can update all attributes for other users
                [:id, :username, :email, :role]
            else
                # Users can only update their own attributes
                [:id, :username, :email]
            end
        end
end
