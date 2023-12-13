class Api::CommentsController < ApplicationController
    before_action :set_post, only: [:index, :create]
    before_action :set_comment, only: [:show, :replies, :reply, :update, :destroy]
    before_action :require_authentication

    # GET api/posts/:post_id/comments
    def index
        # Number of comments to fetch in each request
        per_page = 9

        # Page parameter to determine which set of comments to fetch
        page = params[:page].to_i || 1

        # Calculate the offset based on the number of comments already fetched
        comments_data, pages_left = get_comments_from_page(@post, page, per_page)

        render json: {
            comments: comments_data,
            pages_left: pages_left
        }
    end

    # GET api/posts/comments
    def all
        # Only allow the admin to view all comments
        authorize Comment

        # Number of comments to fetch in each request
        per_page = 9
    
        # Page parameter to determine which set of comments to fetch
        page = params[:page].to_i || 1
    
        # Calculate the offset based on the number of comments already fetched
        offset = (page - 1) * per_page
    
        # Fetch the top-level comments with their reply counts
        comments_data = Comment
                            .where(parent_comment_id: nil)
                            .limit(per_page)
                            .offset(offset)
                            .select('comments.*, COUNT(replies.id) AS replies_count')
                            .joins('LEFT JOIN comments AS replies ON comments.id = replies.parent_comment_id')
                            .group('comments.id')
                            .order(created_at: :desc)
        comments_data = map_comments_with_user_and_post_info(comments_data)

        # Calculate the total number of top-level comments (not considering replies)
        total_comments = Comment.where(parent_comment_id: nil).count

        # Calculate the number of pages left
        pages_left = (total_comments.to_f / per_page).ceil - page

        render json: {
            comments: comments_data,
            pages_left: pages_left
        }
    end

    # GET api/posts/comments/:id
    def show
        # Only allow the admin to view the comment
        authorize @comment

        # Map comment with user and post information and exclude unnecessary fields
        render json: {
            comment: {
                id: @comment.id,
                content: @comment.content,
                created_at: @comment.created_at,
                updated_at: @comment.updated_at,
                user: user_info,
                post: post_info
            }
        }
    end

    # GET api/posts/:post_id/comments/:comment_id/replies
    def replies
        # Number of replies to fetch in each request
        per_page = 9
    
        # Page parameter to determine which set of replies to fetch
        page = params[:page].to_i || 1
    
        # Calculate the offset based on the number of replies already fetched
        offset = (page - 1) * per_page
    
        # Fetch the replies for the specific comment
        replies_result = @comment.replies
                                    .limit(per_page)
                                    .offset(offset)
                                    .order(created_at: :desc)
                                    .map { |reply| format_reply(reply) }
    
        # Calculate the total number of replies for the specific comment
        total_replies = @comment.replies.count
    
        # Calculate the number of pages left for the specific comment
        pages_left = (total_replies.to_f / per_page).ceil - page
    
        render json: {
            replies: replies_result,
            pages_left: pages_left
        }
    end

    # POST api/posts/:post_id/comments
    def create
        # Create a new comment for the post
        @comment = @post.comments.new(comment_params)
        @comment.user = current_user 

        if @comment.save
            render json: { comment: format_reply(@comment) }, status: :created
        else
            render json: { errors: @comment.errors }, status: :unprocessable_entity
        end
    end

    # POST api/posts/:post_id/comments/:comment_id/replies
    def reply
        # Create a new reply for the comment
        @reply = @comment.replies.new(comment_params)
        @reply.user = current_user
        @reply.post = @comment.post
        @reply.parent_comment = @comment
    
        if @reply.save
            render json: { reply: format_reply(@reply) }, status: :created
        else
            render json: { errors: @reply.errors }, status: :unprocessable_entity
        end
    end

    # PUT api/posts/:post_id/comments/:id
    def update
        # Only allow the comment owner or the admin to update the comment
        authorize @comment

        # Update the comment
        if @comment.update(comment_params)
            render json: { comment: format_reply(@comment) }, status: :ok
        else
            render json: { errors: @comment.errors }, status: :unprocessable_entity
        end
    end

    # DELETE api/posts/:post_id/comments/:id
    def destroy
        # Only allow the comment owner or the admin to delete the comment
        authorize @comment

        # Delete the comment
        @comment.destroy
        render json: { message: 'Comment deleted successfully' }, status: :ok
    end
    
    private
        # Use callbacks to share common setup or constraints between actions
        def set_post
            @post = Post.find(params[:post_id])
            render_not_found("Post not found") unless @post
        end

        def set_comment
            @comment = Comment.find(params[:id])
            render_not_found("Comment not found") unless @comment
        end

        # Only allow a trusted parameter "white list" through
        def comment_params
            params.require(:comment).permit(:content)
        end
end
