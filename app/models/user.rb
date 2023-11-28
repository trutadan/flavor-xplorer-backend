class User < ApplicationRecord
    has_secure_password

    attr_accessor :activation_token, :reset_token

    before_save :downcase_email, :downcase_username
    before_validation :set_default_role, on: :create

    VALID_USERNAME_REGEX = /\A[a-zA-Z_][a-zA-Z0-9_]*\z/
    validates :username, presence: true, length: { minimum: 4, maximum: 20 },
                        format: { with: VALID_USERNAME_REGEX, message: "must start with a letter and can only contain letters, numbers, and underscores" },
                        uniqueness: { case_sensitive: false }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }

    VALID_PASSWORD_REGEX = /\A^(?=\S*?[a-z])(?=\S*?[A-Z])(?=\S*?\d)(?=\S*?[\W_])/
    validates :password, presence: true, length: { minimum: 8 }, 
                        format: { with: VALID_PASSWORD_REGEX, message: "must include at least one lowercase letter, one uppercase letter, one digit, and one special character"},
                        allow_nil: true

    enum role: [:regular, :admin]
    validates :role, presence: true, inclusion: { in: roles.keys }

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # Activates an account.
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    # Sends activation email.
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # Sets the password reset attributes.
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    # Sends password reset email.
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # Resets the password.
    def reset_password(params)
        self.update(params)      
        self.update(reset_digest: nil, reset_sent_at: nil)    
    end

    # Returns true if a password reset has expired.
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    # Returns the hash digest of the given string.
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def self.new_token
        SecureRandom.urlsafe_base64
    end

    private
        # Converts email to all lower-case.
        def downcase_email
            email.downcase!
        end

        # Converts username to all lower-case.
        def downcase_username
            username.downcase!
        end

        # Sets the default role to regular, if not already set.
        def set_default_role
            self.role ||= :regular
        end
end
