class RemoveUniqueConstraintFromCommentsIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :comments, name: 'index_comments_on_user_id_and_post_id'
    add_index :comments, ["user_id", "post_id"], name: "index_comments_on_user_id_and_post_id"
  end
end
