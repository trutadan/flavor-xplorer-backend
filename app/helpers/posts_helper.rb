module PostsHelper
    def format_posts_data(posts)
        posts.map do |post|
        {
            id: post.id,
            title: post.title,
            ingredients: post.ingredients,
            instructions: post.instructions,
            cooking_time: post.cooking_time,
            servings: post.servings,
            created_at: post.created_at,
            updated_at: post.updated_at,
            comments_count: comments_count(post),
            rating_mean: post.ratings.average(:value).to_f,
            rating_count: post.ratings.count,
            images: post.images.map { |image| rails_blob_url(image, only_path: true) },
            videos: post.videos.map { |video| rails_blob_url(video, only_path: true) }
        }
        end
    end

    def format_feed_posts_data(posts)
        posts.map do |post|
        {
            id: post.id,
            title: post.title,
            ingredients: post.ingredients,
            instructions: post.instructions,
            cooking_time: post.cooking_time,
            servings: post.servings,
            user: {
                user_id: post.user.id,
                username: post.user.username,
                avatar_url: post.user.user_account&.avatar&.service_url
            },
            created_at: post.created_at,
            updated_at: post.updated_at,
            comments_count: comments_count(post),
            rating_mean: post.ratings.average(:value).to_f,
            rating_count: post.ratings.count,
            images: post.images.map { |image| rails_blob_url(image, only_path: true) },
            videos: post.videos.map { |video| rails_blob_url(video, only_path: true) }
        }
        end
    end

    def format_post_data_details(post)
        {
        id: post.id,
        title: post.title,
        ingredients: post.ingredients,
        instructions: post.instructions,
        cooking_time: post.cooking_time,
        servings: post.servings,
        user: {
            user_id: post.user.id,
            username: post.user.username,
            avatar_url: post.user.user_account&.avatar&.service_url
        },
        created_at: post.created_at,
        updated_at: post.updated_at,
        comments: format_comments_data(paginated_comments(post.comments), []),
        rating_mean: post.ratings.average(:value).to_f,
        rating_count: post.ratings.count,
        images: post.images.map { |image| rails_blob_url(image, only_path: true) },
        videos: post.videos.map { |video| rails_blob_url(video, only_path: true) }
        }
    end
end