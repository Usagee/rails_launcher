model(:user) { string 'user_name' }
model(:blog) { string 'title' }
user.has_one blog
