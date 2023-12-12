module CommentsHelper
  # Map comments with user information and exclude unnecessary fields
  def map_comments_with_user_info(comments)
    comments.map do |comment|
    {
      id: comment.id,
      content: comment.content,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      user: {
        user_id: comment.user_id,
        username: comment.user.username,
        avatar: comment.user.user_account&.avatar&.service_url
      },
      replies_count: comment.replies_count
    }
    end
  end

  # Map comments with user and post information and exclude unnecessary fields
  def map_comments_with_user_and_post_info(comments)
    comments.map do |comment|
    {
      id: comment.id,
      content: comment.content,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      user: {
        user_id: comment.user_id,
        username: comment.user.username,
        avatar: comment.user.user_account&.avatar&.service_url
      },
      post: {
        post_id: comment.post_id,
        title: comment.post.title
      },
      replies_count: comment.replies_count
    }
    end
  end

  # Map replies with user information and exclude unnecessary fields
  def format_reply(reply)
    {
      id: reply.id,
      content: reply.content,
      created_at: reply.created_at,
      updated_at: reply.updated_at,
      user: {
        user_id: reply.user_id,
        username: reply.user.username,
        avatar: reply.user.user_account&.avatar&.service_url
      }
    }
  end

  def get_comments_from_page(post, page, per_page)
    # Calculate the offset based on the number of comments already fetched
    offset = (page - 1) * per_page

    # Fetch the top-level comments with their reply counts for the specific post
    comments_data = @post.comments
                            # Top-level comments only
                            .where(parent_comment_id: nil)
                            .limit(per_page)
                            .offset(offset)
                            .select('comments.*, COUNT(replies.id) AS replies_count')
                            .joins('LEFT JOIN comments AS replies ON comments.id = replies.parent_comment_id')
                            .group('comments.id')
                            .order(created_at: :desc)
    comments_data = map_comments_with_user_info(comments_data)

    # Calculate the total number of top-level comments (not considering replies) for the specific post
    total_comments = @post.comments.where(parent_comment_id: nil).count

    # Calculate the number of pages left for the specific post
    pages_left = (total_comments.to_f / per_page).ceil - page

    return comments_data, pages_left
  end

  
  # Use for response data formatting
  def user_info
    {
      user_id: @comment.user_id,
      username: @comment.user.username,
      avatar: @comment.user.user_account&.avatar&.service_url
    }
  end
    
  # Use for response data formatting
  def post_info
    {
        post_id: @comment.post_id,
        post_title: @comment.post.title
    }
  end
end
