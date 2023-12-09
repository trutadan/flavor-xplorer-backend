class AddKeysAndIndexesToBookmarks < ActiveRecord::Migration[7.1]
  def change
    add_reference :bookmarks, :user, null: false, foreign_key: true
    add_reference :bookmarks, :post, null: false, foreign_key: true
    
    add_index :bookmarks, [:user_id, :post_id], unique: true
  end
end
