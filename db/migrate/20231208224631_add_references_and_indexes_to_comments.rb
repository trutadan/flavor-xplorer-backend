class AddReferencesAndIndexesToComments < ActiveRecord::Migration[7.1]
  def change
    add_reference :comments, :parent_comment, foreign_key: { to_table: :comments }

    add_column :comments, :user_id, :integer
    add_index :comments, :user_id

    add_column :comments, :post_id, :integer
    add_index :comments, :post_id

    add_index :comments, [:user_id, :post_id], unique: true
  end
end
