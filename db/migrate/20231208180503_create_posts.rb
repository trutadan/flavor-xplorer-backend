class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :ingredients
      t.text :instructions
      t.integer :cooking_time
      t.integer :servings

      t.timestamps
    end
  end
end
