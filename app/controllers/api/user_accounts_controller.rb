class Api::UserAccountsController < ApplicationController
    def index
        @user_accounts = UserAccount.all.order(created_at: :desc).paginate(page: params[:page], per_page: 25)
        @total_pages = @user_accounts.total_pages

        render json: {
            user_accounts: JSON.parse(@user_accounts.to_json(only: user_account_params)),
            total_pages: @total_pages
        }
    end

    def show
        @user_account = UserAccount.find(params[:id])

        if @user_account
            render json: JSON.parse(@user_account.to_json(only: user_account_params))
        else
            render_not_found("User account not found.")
        end
    end

    def update
        @user_account = UserAccount.find(params[:id])

        if @user_account.update(user_account_params)
            render json: JSON.parse(@user_account.to_json(only: user_account_params))
        else
            render json: @user_account.errors, status: :unprocessable_entity
        end
    end

    private
        def user_account_params
            [:first_name, :last_name, :description, :pronouns, :gender]
        end
end
