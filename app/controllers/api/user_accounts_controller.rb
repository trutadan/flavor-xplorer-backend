class Api::UserAccountsController < ApplicationController
    before_action :set_user_account, only: [:show, :update]
    before_action :require_authentication

    # GET api/users/accounts
    def index
        # Only admins can view all user accounts
        authorize UserAccount

        @user_accounts = UserAccount.all.order(created_at: :desc).paginate(page: params[:page], per_page: 25)
        @total_pages = @user_accounts.total_pages

        render json: {
            user_accounts: JSON.parse(@user_accounts.to_json(only: user_account_info_params)),
            total_pages: @total_pages
        }
    end

    # GET api/users/1/account
    def show
        # Only admins and the account owner can view the user account
        authorize @user_account

        render json: JSON.parse(@user_account.to_json(only: user_account_info_params))
    end

    # PATCH/PUT api/users/1/account
    def update
        # Only admins and the account owner can update the user account
        authorize @user_account
        
        if @user_account.update(user_account_params)
            render json: JSON.parse(@user_account.to_json(only: user_account_info_params))
        else
            render json: { errors: @user_account.errors }, status: :unprocessable_entity
        end
    end

    private
        def user_account_info_params
            [:first_name, :last_name, :description, :pronouns, :gender]
        end

        def user_account_params
            params.require(:user_account).permit(user_account_info_params)
        end

        def set_user_account
            @user = User.find(params[:user_id])
            render_not_found("User not found.") unless @user                
            @user_account = @user.user_account
            render_not_found("User account not found.") unless @user_account
        end
end
