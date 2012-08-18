require 'spec_helper'

describe RailsLauncher::FileConstructor do
  let(:simple_world) do
    RailsLauncher::DSL.new_world_block { model(:user) { string 'user_name' } }
  end

  let(:two_models) do
    RailsLauncher::DSL.new_world_block do
      model(:user) { string 'user_name' }
      model(:post) { string 'title' }
    end
  end

  describe 'files for the simple world' do
    subject(:constructor) { described_class.new(simple_world) }

    it 'should create User model file' do
      content_of_file('app/models/user.rb').should eq <<RUBY
class User
  attr_accessor :user_name
end
RUBY
    end

    it 'should create a migration file for users table' do
      content_of_file('db/migrate/001_create_users.rb').should eq <<RUBY
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name
      t.timestamps
    end
  end
end
RUBY
    end
  end

  describe 'files for simple two models without relationship' do
    subject(:constructor) { described_class.new(two_models) }

    it 'should create Post model file' do
      content_of_file('app/models/post.rb').should eq <<RUBY
class Post
  attr_accessor :title
end
RUBY
    end

    it 'should have migration files for posts and users tables' do
      content_of_file('db/migrate/\d\d\d_create_users.rb').should_not be_empty
      content_of_file('db/migrate/\d\d\d_create_posts.rb').should_not be_empty
    end
  end

  def content_of_file(path_regexp)
    matches = subject.file_entities.select { |f| f.path.match path_regexp }
    case matches.size
    when 0
      fail("#{path_regexp} is expected to match a file constructed, but nothing matched")
    when 1
      return matches.first.file_content
    else
      fail("#{path_regexp} matches more than a file. " + matches.map(&:path).join(', '))
    end
  end
end
