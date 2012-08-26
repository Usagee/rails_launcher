require 'spec_helper'

describe RailsLauncher::DSL do
  describe 'world with single model' do
    subject(:world) { sample_world('simple') }

    it { should have(1).models }

    it 'user model should have user_name field' do
      expect(subject.models.first.fields.first).to eq(['string', 'user_name'])
    end
  end

  describe 'two models with has_one relationship' do
    subject(:world) { sample_world('has_one') }

    it { should have(2).models }
    specify 'user model should have one blog' do
      expect(model(:user).relations.first).to eq(['has_one', :blog])
    end

    specify 'blog model should belong to an user' do
      expect(model(:blog).relations.first).to eq(['belongs_to', :user])
    end
  end

  describe 'two models with has_many relationship' do
    subject(:world) { sample_world('has_many') }

    specify 'user model should have many posts' do
      expect(model(:user).relations.first).to eq(['has_many', :posts])
    end

    specify 'post model should belongs to an user' do
      expect(model(:post).relations.first).to eq(['belongs_to', :user])
    end
  end

  describe 'two models and a medium model for has_many_through' do
    subject(:world) { RailsLauncher::DSL.new_world %q{
model(:user) { string 'user_name' }
model(:post) { string 'title' }
model(:comment) { string 'content' }
user.has_many posts, through: comments
} }

    specify 'user model should have many comments' do
      expect(model(:user).relations).to include(['has_many', :comments])
    end

    specify 'user model should have many posts through comments' do
      expect(model(:user).relations).to include(['has_many', :posts, through: :comments])
    end

    specify 'post model should have many comments' do
      expect(model(:post).relations).to include(['has_many', :comments])
    end

    specify 'post model should have many users through comments' do
      expect(model(:post).relations).to include(['has_many', :users, through: :comments])
    end
  end

  describe 'has_many without medium declaration' do
    subject(:world) { RailsLauncher::DSL.new_world %q{
model(:user) { string 'user_name' }
model(:post) { string 'title' }
user.has_many posts, through: :comments
} }

    specify 'user model should have many comments' do
      expect(model(:user).relations).to include(['has_many', :comments])
    end

    specify 'user model should have many posts through comments' do
      expect(model(:user).relations).to include(['has_many', :posts, through: :comments])
    end

    specify 'world should have comment model' do
      expect(model(:comment)).not_to be_nil
    end
  end

  def model(name)
    world.models.find { |m| m.name == name }
  end
end
