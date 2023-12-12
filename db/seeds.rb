# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create an admin user
admin = User.create!(
  username: 'admin',
  email: 'admin@example.com',
  password: 'Pa$$w0rd',
  password_confirmation: 'Pa$$w0rd',
  role: User.roles["admin"],
  activated: true
)

# Create a regular user
user = User.create!(
  username: "user",
  email: "user@example.com",
  password: 'Pa$$w0rd',
  password_confirmation: 'Pa$$w0rd',
  role: User.roles["regular"],
  activated: true
)

# Create a user account for the admin user
admin_account = UserAccount.create!(
  first_name: 'Admin',
  last_name: 'User',
  gender: UserAccount.genders["male"],
  user_id: admin.id
)

# Create a user account for the regular user
user_account = UserAccount.create!(
  first_name: 'Regular',
  last_name: 'User',
  gender: UserAccount.genders["prefer_not_to_say"],
  user_id: user.id
)

# Seed data for Posts
admin_post = Post.create!(
  title: 'Admin Post',
  ingredients: 'Ingredient 1, Ingredient 2',
  instructions: 'Step 1, Step 2',
  cooking_time: 30,
  servings: 4,
  user_id: admin.id
)

user_post = Post.create!(
  title: 'User Post',
  ingredients: 'Ingredient A, Ingredient B',
  instructions: 'Step A, Step B',
  cooking_time: 45,
  servings: 2,
  user_id: user.id
)

# Seed data for Ratings
Rating.create!(
  value: 4,
  user_id: admin.id,
  post_id: user_post.id
)

Rating.create!(
  value: 5,
  user_id: user.id,
  post_id: admin_post.id
)

# Seed data for Comments
Comment.create!(
  content: 'Great post!',
  user_id: admin.id,
  post_id: user_post.id
)

Comment.create!(
  content: 'Awesome!',
  user_id: user.id,
  post_id: admin_post.id
)

30.times do
  Comment.create!(
    content: Faker::Lorem.sentence,
    user_id: User.all.sample.id,
    post_id: user_post.id
  )
end

30.times do
  Comment.create!(
    content: Faker::Lorem.sentence,
    user_id: User.all.sample.id,
    post_id: admin_post.id
  )
end

# Seed data for Replies
Comment.all.each do |comment|
  rand(0..5).times do
    Comment.create!(
      content: Faker::Lorem.sentence,
      user_id: User.all.sample.id,
      post_id: comment.post_id,
      parent_comment_id: comment.id
    )
  end
end