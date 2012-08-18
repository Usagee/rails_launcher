model(:user) { string 'user_name' }
model(:post) { string 'title' }
user.has_many posts
