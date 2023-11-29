class ApplicationController < ActionController::API
    include SessionsHelper

    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized

    private
        def render_unauthorized(message = 'You are not authorized to perform this action.')
            render json: { error: message }, status: :unauthorized
        end

        def require_authentication
            render_unauthorized("You must be logged in to perform this action.") unless logged_in?
        end
        
        def require_admin
            render_unauthorized("You do not have permission to perform this action.") unless current_user&.admin?
        end

        def render_not_found(message = 'Entity not found.')
            render json: { error: message }, status: :not_found
        end
end
