module SessionsHelper
    # Logs in the user and returns a JWT token with a one-day expiration time.
    def log_in(user)
        expiration_time = 1.day.from_now.to_i
        payload = { user_id: user.id, exp: expiration_time }
        JWT.encode(payload, Rails.application.config.jwt_secret_key, 'HS256')
    end
    
    # Gets the current user from the JWT token and checks for expiration.
    def current_user
        if request.headers['Authorization'].present?
            token = request.headers['Authorization'].split(' ').last
            begin
                decoded_token = JWT.decode(token, Rails.application.config.jwt_secret_key, true, { algorithm: 'HS256' })
                user_id = decoded_token.first['user_id']
                if decoded_token.first['exp'].nil? || decoded_token.first['exp'] >= Time.now.to_i
                    @current_user ||= User.find_by(id: user_id)
                else
                    @current_user = nil
                end
            rescue JWT::DecodeError
                @current_user = nil
            end
        end
    end     

    # Returns true if the user is logged in, false otherwise.
    def logged_in?
        !current_user.nil?
    end

    # Returns true if the given user is the current user.
    def current_user?(user)
        user && user == current_user
    end
end
