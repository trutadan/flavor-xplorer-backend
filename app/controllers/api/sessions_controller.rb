class Api::SessionsController < ApplicationController
    # POST api/login
    def create
        user = User.find_by(email_or_username => params[:identifier].downcase)
        if user&.authenticate(params[:password])
            token = log_in(user)
            render json: { message: 'Logged in successfully', token: token, user_id: user.id, username: user.username, role: user.role }, status: :ok
        else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
    end

    # DELETE api/logout
    def destroy
        render json: { message: 'Logged out successfully' }, status: :ok
    end

    private
        # Returns the symbol for the email or username field.
        def email_or_username
            params[:identifier].include?('@') ? :email : :username
        end
end
