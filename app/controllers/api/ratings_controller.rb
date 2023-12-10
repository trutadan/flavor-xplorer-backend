class Api::RatingsController < ApplicationController
    before_action :set_post, only: [:index]
    before_action :set_rate_post, only: [:rate]
    before_action :require_authentication

    # GET api/posts/:post_id/ratings
    def index
        authorize Rating

        # Return all ratings for the post in descending order of creation date
        @ratings = @post.ratings.order(created_at: :desc).paginate(page: params[:page], per_page: 25)
        @total_pages = @ratings.total_pages

        # Format data for response
        @ratings_data = format_ratings_data(@ratings)

        render json: {
            ratings: @ratings_data,
            total_pages: @total_pages
        }, status: :ok
    end

    # GET api/posts/ratings
    def all
        authorize Rating

        # Return all ratings in descending order of creation date
        @ratings = Rating.all.order(created_at: :desc).paginate(page: params[:page], per_page: 25)
        @total_pages = @ratings.total_pages

        # Format data for response
        @ratings_data = format_ratings_data(@ratings)

        render json: {
            ratings: @ratings_data,
            total_pages: @total_pages
        }, status: :ok
    end

    # POST api/posts/:post_id/rate
    def rate
        @existing_rating = current_user.ratings.find_by(post: @post)
    
        if @existing_rating.nil?
            # If the post has not been rated, create a new rating
            @rating = current_user.ratings.build(rating_params.merge(post_id: @post.id))
            if @rating.save
                render json: { message: "Rating has been successfully created" }, status: :created
            else
                render json: { errors: @rating.errors }, status: :unprocessable_entity
            end
        else
            if rating_params[:value].to_i == @existing_rating.value
                # If the value is the same, delete the existing rating
                @existing_rating.destroy
                render json: { message: "Rating has been successfully deleted" }, status: :ok
            else
                # If a new value is provided, update the existing rating
                if @existing_rating.update(rating_params)
                    render json: { message: "Rating has been successfully updated" }, status: :ok
                else
                    render json: { errors: @existing_rating.errors }, status: :unprocessable_entity
                end
            end
        end
    end
  
    private
        # Only allow a trusted parameter "white list" through
        def rating_params
            params.require(:rating).permit(:value)
        end

        # Use callbacks to share common setup or constraints between actions
        def set_post
            @post = Post.find(params[:post_id])
            render_not_found("Post not found") unless @post
        end

        def set_rate_post
            @post = Post.find(params[:id])
            render_not_found("Post not found") unless @post
        end
end
