require 'spec_helper'

describe RailsLauncher::FileConstructor do
  let(:simple_world) do
    w = RailsLauncher::DSL.new_world
    w.instance_eval { model(:user) { string 'user_name' } }
    w
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
