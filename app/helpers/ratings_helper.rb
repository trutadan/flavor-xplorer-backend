module RatingsHelper
    def format_ratings_data(ratings)
        ratings.map do |rating|
            {
                id: rating.id,
                value: rating.value,
                user: {
                    id: rating.user.id,
                    username: rating.user.username,
                }
            }
        end
    end
end
