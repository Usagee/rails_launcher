model(:user) { string 'user_name' }
model(:post) { string 'title' }
model(:comment) { string 'content' }
user.has_many posts, through: comments
