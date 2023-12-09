class Api::PostsController < ApplicationController
    before_action :set_post, only: [:show, :update, :destroy]
    before_action :require_authentication

    # GET api/posts
    def index
        # Return all posts in descending order of creation date
        @user_posts = current_user.posts.order(created_at: :desc).paginate(page: params[:page], per_page: 9)
        @total_pages = @user_posts.total_pages
    
        # Format data for response
        @posts_data = format_posts_data(@user_posts)
    
        render json: {
            user_posts: @posts_data,
            total_pages: @total_pages
        }, status: :ok
    end

    # GET api/posts/feed
    def feed
        # Return all posts created by the users that the current user is following
        @followed_users_posts = current_user.following.includes(:posts).map(&:posts).flatten
        @feed_posts = Post.where(id: @followed_users_posts.map(&:id)).order(created_at: :desc).paginate(page: params[:page], per_page: 9)
        @total_pages = @feed_posts.total_pages
    
        # Format data for response
        @feed_posts_data = format_feed_posts_data(@feed_posts)
    
        render json: {
            feed_posts: @feed_posts_data,
            total_pages: @total_pages
        }, status: :ok
    end

    # GET api/posts/explore
    def explore
        query = params[:query]
    
        if query.present? 
            # Search for posts whose titles or instructions contain the query string
            @explore_posts = Post.where("title ILIKE :query OR instructions ILIKE :query", query: "%#{query}%")
        else
            # Return all posts except the ones created by the users that the current user is following
            @explore_posts = Post.where.not(user_id: current_user.following_ids)
        end
    
        # Exclude the current user's posts
        @explore_posts = @explore_posts.where.not(user_id: current_user.id)

        # Custom sorting by rating (desc), number of comments (desc), and created_at (desc)
        @explore_posts = @explore_posts.sort do |a, b|
            b.ratings.average(:value).to_f <=> a.ratings.average(:value).to_f
        end.sort_by { |post| [post.comments.count, post.created_at] }.reverse
    
        # Convert to ActiveRecord relation to use pagination
        @explore_posts = Post.where(id: @explore_posts.map(&:id))
    
        # Pagination and total pages
        @paginated_posts = @explore_posts.paginate(page: params[:page], per_page: 9)
        @total_pages = @paginated_posts.total_pages
    
        # Format data for response
        @explore_posts_data = format_feed_posts_data(@paginated_posts)
    
        render json: {
            explore_posts: @explore_posts_data,
            total_pages: @total_pages
        }, status: :ok
    end

    # GET api/posts/:id
    def show
        # Format data for response
        @post_data = format_post_data_details(@post)
    
        render json: @post_data, status: :ok
    end

    # POST api/posts
    def create
        @post = current_user.posts.build(post_params)
    
        if @post.save
            render json: "Post has been successfully created", status: :created
        else
            render json: { errors: @post.errors }, status: :unprocessable_entity
        end
    end

    # PATCH/PUT api/posts/:id
    def update
        # Only the post owner and the admin can update the post
        authorize @post

        if @post.update(post_params)
            render json: format_post_data_details(@post), status: :ok
        else
            render json: { errors: @post.errors }, status: :unprocessable_entity
        end
    end

    # DELETE api/posts/:id
    def destroy
        # Only the post owner and the admin can delete the post
        authorize @post

        @post.destroy
        render json: { message: "Post has been successfully deleted" }, status: :ok
    end

    private
        # Use callback to share common setup or constraints between actions
        def set_post
            @post = Post.find(params[:id])
            render_not_found("Post not found") unless @post
        end

        # Only allow a trusted parameter "white list" through
        def post_params
            params.require(:post).permit(:title, :ingredients, :instructions, :cooking_time, :servings, images: [], videos: [])
        end
end
