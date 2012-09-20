=begin rdoc
= Factory Girl Plugin

factory_girl[https://github.com/thoughtbot/factory_girl] plugin for rails_launcher.

This plugin creates factory files according to the model definitions.

For example, with this definition (which is in sample_worlds as has_many.rb)

    model(:user) { string 'user_name' }
    model(:post) { string 'title' }
    user.has_many posts

You get following two files.

+test/factories/users.rb+

    FactoryGirl.define do
      factory :user do
        name "TestString"
      end
    end

+test/factories/posts.rb+

    FactoryGirl.define do
      factory :post do
        title "TestString"
        user
      end
    end

== Configuration

- +root_path+: Path to place factory files, relative to the Rails root.
=end

module RailsLauncher::Plugin
  class FactoryGirl
    
  end
end
