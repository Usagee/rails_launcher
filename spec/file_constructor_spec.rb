require 'spec_helper'

describe RailsLauncher::FileConstructor do
  let(:world) { sample_world(world_name) }

  # to avoid stack level too deep
  let(:constructor) { described_class.new(world) }
  subject { constructor }

  describe 'files for the simple world' do
    let(:world_name) { 'simple' }

    it 'should create User model file' do
      expect(content_of_file('app/models/user.rb')).to eq <<RUBY
class User
  attr_accessible :user_name
end
RUBY
    end

    it 'should create a migration file for users table' do
      expect(content_of_file('db/migrate/001_create_users.rb')).to eq <<RUBY
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
    let(:world_name) { 'two_models' }

    it 'should create Post model file' do
      expect(content_of_file('app/models/post.rb')).to eq <<RUBY
class Post
  attr_accessible :title
end
RUBY
    end

    it 'should create Post migration file' do
      expect(content_of_file('db/migrate/\d\d\d_create_posts.rb')).to match /t.string :title/
    end

    it 'should have migration files for posts and users tables' do
      expect(content_of_file('db/migrate/\d\d\d_create_users.rb')).not_to be_empty
      expect(content_of_file('db/migrate/\d\d\d_create_posts.rb')).not_to be_empty
    end
  end

  describe 'files for has_one relationship' do
    let(:world_name) { 'has_one' }

    specify 'User model file should contain has_one' do
      expect(content_of_file('app/models/user.rb')).to match(/^\s*has_one :blog$/)
    end

    specify 'Blog model should contain belongs to user' do
      expect(content_of_file('app/models/blog.rb')).to match(/^\s*belongs_to :user$/)
    end

    specify 'blogs migration should contain user reference and index for it' do
      migration = content_of_file('db/migrate/\d\d\d_create_blogs.rb')
      expect(migration).to match(/^\s*t.references :user$/)
      expect(migration).to match(/^\s*add_index :blogs, :user_id$/)
    end
  end

  describe 'files for has_many relationship' do
    let(:world_name) { 'has_many' }

    specify 'User model file should contain has_many' do
      expect(content_of_file('app/models/user.rb')).to match(/^\s*has_many :posts$/)
    end
  end

  describe 'files for has_many_through' do
    let(:world_name) { 'has_many_through' }

    context 'User model file' do
      subject { content_of_file('app/models/user.rb') }
      it { should match(/^\s*has_many :comments$/) }
      it { should match(/^\s*has_many :posts, through: :comments$/) }
    end

    context 'Post model file' do
      subject { content_of_file('app/models/post.rb') }
      it { should match(/^\s*has_many :comments$/) }
      it { should match(/^\s*has_many :users, through: :comments$/) }
    end

    context 'Comment model file' do
      subject { content_of_file('app/models/comment.rb') }
      it { should match(/^\s*belongs_to :user$/) }
      it { should match(/^\s*belongs_to :post$/) }
    end

    context 'Comment migration file' do
      subject { content_of_file('db/migrate/\d\d\d_create_comments.rb') }
      it { should match(/^\s*t.references :user$/) }
      it { should match(/^\s*add_index :comments, :user_id$/) }
      it { should match(/^\s*t.references :post$/) }
      it { should match(/^\s*add_index :comments, :post_id$/) }
    end
  end

  def content_of_file(path_regexp)
    matches = constructor.file_entities.select { |f| f.path.match path_regexp }
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
