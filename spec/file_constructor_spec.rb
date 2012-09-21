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
class User < ActiveRecord::Base
  attr_accessible :user_name
end
RUBY
    end

    it 'should create a migration file for users table' do
      expect(content_of_file('db/migrate/001_create_users.rb').gsub(/\n+/, "\n")).to eq <<RUBY
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

    context 'UsersController' do
      subject { content_of_file('app/controllers/users_controller.rb') }

      it { should match_line "class UsersController < ApplicationController" }
      it { should match_line "def index" }
      it { should match_line "@users = User.all" }
      it { should match_line "def show" }
      it { should match_line "def new" }
      it { should match_line "def edit" }
      # this does not match with string, because of special chars
      it { should match_line /@user = User.find\(params\[:id\]\)/ }
      it { should match_line "def create" }
      it { should match_line "def update" }
      it { should match_line "def destroy" }
    end

    describe 'view files' do
      describe 'index' do
        subject(:index_view) { content_of_file('app/views/users/index.html.haml') }
        it { should match "Listing users" }
        it { should match_line '- @users.each do |user|' }
        it { should match_line '%td= user.user_name' }
        it { should match_line "%td= link_to 'Show', user" }
        it { should match "link_to 'Edit'" }
        it { should match %q{%td= link_to 'Destroy', user} }
      end

      describe 'form' do
        subject(:form_view) { content_of_file('app/views/users/_form.html.haml') }
        it { should match "= f.submit 'Save'" }
      end
    end
  end

  describe 'files for simple two models without relationship' do
    let(:world_name) { 'two_models' }

    it 'should create Post model file' do
      expect(content_of_file('app/models/post.rb')).to eq <<RUBY
class Post < ActiveRecord::Base
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
      expect(content_of_file('app/models/user.rb')).to match_line "has_one :blog"
    end

    specify 'Blog model should contain belongs to user' do
      expect(content_of_file('app/models/blog.rb')).to match_line "belongs_to :user"
    end

    specify 'blogs migration should contain user reference and index for it' do
      migration = content_of_file('db/migrate/\d\d\d_create_blogs.rb')
      expect(migration).to match_line "t.references :user"
      expect(migration).to match_line "add_index :blogs, :user_id"
    end
  end

  describe 'files for has_many relationship' do
    let(:world_name) { 'has_many' }

    specify 'User model file should contain has_many' do
      expect(content_of_file('app/models/user.rb')).to match_line "has_many :posts"
    end
  end

  describe 'files for has_many_through' do
    let(:world_name) { 'has_many_through' }

    context 'User model file' do
      subject { content_of_file('app/models/user.rb') }
      it { should match_line "has_many :comments" }
      it { should match_line "has_many :posts, through: :comments" }
    end

    context 'Post model file' do
      subject { content_of_file('app/models/post.rb') }
      it { should match_line "has_many :comments" }
      it { should match_line "has_many :users, through: :comments" }
    end

    context 'Comment model file' do
      subject { content_of_file('app/models/comment.rb') }
      it { should match_line "belongs_to :user" }
      it { should match_line "belongs_to :post" }
    end

    context 'Comment migration file' do
      subject { content_of_file('db/migrate/\d\d\d_create_comments.rb') }
      it { should match_line "t.references :user" }
      it { should match_line "add_index :comments, :user_id" }
      it { should match_line "t.references :post" }
      it { should match_line "add_index :comments, :post_id" }
    end
  end

  describe 'routing' do
    let(:world_name) { 'index_routing' }

    context 'welcome controller' do
      subject(:controller) { content_of_file('app/controllers/welcome_controller.rb') }
      it { should match "class WelcomeController" }
      it { should match_line "def index" }
    end

    context 'view file for a no-model controller' do
      subject(:index_view) { content_of_file('app/views/welcome/index.html.haml') }
      it { should match "welcome#index" }
    end

    context 'routes.rb' do
      subject { content_of_file('config/routes.rb') }

      it { should match 'IndexOnlyApplication::Application.routes' }
      it { should match_line 'root {:to=>"welcome#index"}' }
    end

    context 'when no routing is explicitly defined' do
      let(:world_name) { 'simple' }
      subject { content_of_file('config/routes.rb') }
      it { should match 'YourApplicationName::Application.routes' }
    end
  end
end
