class ChangeGenderColumnType < ActiveRecord::Migration[7.1]
  def up
    change_column :user_accounts, :gender, 'integer USING CAST(gender AS integer)'
  end

  def down
    change_column :user_accounts, :gender, :string
  end
end
