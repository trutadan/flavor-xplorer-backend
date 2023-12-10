module BookmarksHelper
    def format_bookmarks_data(bookmarks)
        bookmarks.map do |bookmark|
            {
                id: bookmark.id,
                user: {
                    id: bookmark.user.id,
                    username: bookmark.user.username
                },
                post: {
                    id: bookmark.post.id,
                    title: bookmark.post.title,
                    instructions: bookmark.post.instructions
                },
                created_at: bookmark.created_at,
            }
        end
    end
end
