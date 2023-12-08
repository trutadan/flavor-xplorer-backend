class AddIndexesToRatings < ActiveRecord::Migration[7.1]
  def change
    add_column :ratings, :user_id, :integer
    add_index :ratings, :user_id

    add_column :ratings, :post_id, :integer
    add_index :ratings, :post_id

    add_index :ratings, [:user_id, :post_id], unique: true
  end
end
