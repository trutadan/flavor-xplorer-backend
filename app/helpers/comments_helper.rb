module CommentsHelper
  def format_comments_data(comments, replies)
    comments.map do |comment|
      {
        id: comment.id,
        content: comment.content,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        user: {
          user_id: comment.user.id,
          username: comment.user.username,
          avatar_url: comment.user.user_account&.avatar&.service_url
        },
        replies: format_repliess_data(replies)
      }
    end
  end

  def format_repliess_data(replies)
    replies.map do |reply|
      {
        id: reply.id,
        content: reply.content,
        created_at: reply.created_at,
        updated_at: reply.updated_at,
        user: {
          user_id: reply.user.id,
          username: reply.user.username,
          avatar_url: reply.user.user_account&.avatar&.service_url
        }
      }
    end
  end

  def comments_count(post)
    post.comments.count + post.comments.joins(:replies).count
  end

  def paginated_comments(comments, page = 1, per_page = 9)
    comments.order(created_at: :desc).paginate(page: page, per_page: per_page)
  end
end