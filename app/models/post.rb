class Post < ApplicationRecord
    belongs_to :user

    has_many :ratings, dependent: :destroy
    has_many :comments, dependent: :destroy

    has_many :bookmarks, dependent: :destroy
    has_many :bookmarking_users, through: :bookmarks, source: :user

    has_many_attached :images
    validate :validate_images_size
    validate :validate_images_format

    has_many_attached :videos
    validate :validate_videos_size
    validate :validate_videos_format

    default_scope -> { order(created_at: :desc) }

    validates :user_id, presence: true

    validates :title, presence: true, length: { minimum: 5, maximum: 56 }
    validates :ingredients, presence: true, length: { minimum: 10 , maximum: 1000 }
    validates :instructions, presence: true, length: { minimum: 10 , maximum: 1000 }
    validates :cooking_time, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 1440 }, allow_nil: true
    validates :servings, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }, allow_nil: true

    private
        def validate_images_size
            images.each do |image|
                if image.blob.byte_size > 5.megabytes
                    errors.add(:images, 'file size must be less than 5MB')
                end
            end
        end

        def validate_images_format
            images.each do |image|
                unless image.content_type.in?(%w(image/jpeg image/jpg image/png))
                    errors.add(:images, 'must be a JPG, JPEG or PNG')
                end
            end
        end
        
        def validate_videos_size
            videos.each do |video|
                if video.blob.byte_size > 5.megabytes
                    errors.add(:videos, 'file size must be less than 5MB')
                end
            end
        end
        
        def validate_videos_format
            videos.each do |video|
                unless video.content_type.in?(%w(video/mp4 video/mov))
                    errors.add(:videos, 'must be a MP4 or MOV')
                end
            end
        end
end
