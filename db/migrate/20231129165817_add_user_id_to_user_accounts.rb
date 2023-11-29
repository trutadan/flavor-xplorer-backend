class AddUserIdToUserAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :user_accounts, :user_id, :integer
    add_index :user_accounts, :user_id, unique: true
  end
end
