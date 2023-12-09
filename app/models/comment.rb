class Comment < ApplicationRecord
    belongs_to :user
    belongs_to :post

    default_scope -> { order(created_at: :desc) }
    
    belongs_to :parent_comment, class_name: 'Comment', optional: true
    has_many :replies, class_name: 'Comment', foreign_key: 'parent_comment_id', dependent: :destroy
  
    validates :content, presence: true, length: { minimum: 1, maximum: 200 }
end
