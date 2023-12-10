class Api::BookmarksController < ApplicationController
    before_action :set_post, only: [:bookmark, :unbookmark]
    before_action :require_authentication

    # GET api/posts/bookmarks
    def index
        # Return all bookmarked posts in descending order of creation date of the bookmark
        @bookmarked_posts = current_user.bookmarked_posts
                                            .joins(:bookmarks)
                                            .order('bookmarks.created_at DESC')
                                            .paginate(page: params[:page], per_page: 9)
        @total_pages = @bookmarked_posts.total_pages

        # Format data for response
        @bookmarked_posts_data = format_posts_data(@bookmarked_posts)

        render json: {
            bookmarks: @bookmarked_posts_data,
            total_pages: @total_pages
        }, status: :ok
    end

    # POST api/posts/:id/bookmark
    def bookmark
        begin
            current_user.bookmark(@post)
            render json: { message: "Post has been successfully bookmarked" }, status: :ok
        rescue ArgumentError => error
            render json: { errors: error.message }, status: :unprocessable_entity
        end
    end

    # DELETE api/posts/:id/unbookmark
    def unbookmark
        begin
            current_user.unbookmark(@post)
            render json: { message: "Post has been successfully unbookmarked" }, status: :ok
        rescue ArgumentError => error
            render json: { errors: error.message }, status: :unprocessable_entity
        end
    end

    private
        # Use callbacks to share common setup or constraints between actions
        def set_post
            @post = Post.find(params[:id])
            render_not_found("Post not found") unless @post
        end
end
