class CreateUserAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :user_accounts do |t|
      t.string :first_name
      t.string :last_name
      t.string :description
      t.string :pronouns
      t.string :gender

      t.timestamps
    end
  end
end
