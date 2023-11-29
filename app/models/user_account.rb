class UserAccount < ApplicationRecord
    belongs_to :user
    validates :user_id, presence: true

    has_one_attached :avatar
    validate :validate_avatar_size
    validate :validate_avatar_format

    VALID_NAME_REGEX = /\A[a-zA-Z]+\z/
    validates :first_name, :last_name, presence: true, length: { maximum: 50 }, 
                        format: { with: VALID_NAME_REGEX, message: "can only contain letters" }
    
    validates :description, length: { maximum: 150 }, allow_nil: true, allow_blank: true

    VALID_PRONOUNS_REGEX = /\A[a-zA-Z\/]+\z/
    validates :pronouns, length: { maximum: 50 }, allow_nil: true, allow_blank: true, 
                        format: { with: VALID_PRONOUNS_REGEX, message: "can only contain letters and forward slashes" }, 

    enum gender: [:male, :female, :prefer_not_to_say]
    validates :gender, presence: true, inclusion: { in genders.keys }

    private 
        def validate_avatar_size
            if avatar.attached? && avatar.blob.byte_size > 5.megabytes
                errors.add(:avatar, 'file size must be less than 5MB')
            end
        end

        def validate_avatar_format
            if avatar.attached? && !avatar.content_type.in?(%w(image/jpeg image/jpg image/png))
                errors.add(:avatar, 'must be a JPG, JPEG or PNG')
            end
        end
end
