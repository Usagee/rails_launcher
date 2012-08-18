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

  def model(name)
    world.models.find { |m| m.name == name }
  end
end
