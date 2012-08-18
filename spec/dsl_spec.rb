require 'spec_helper'

describe RailsLauncher::DSL do
  describe 'world with single model' do
    subject(:world) { RailsLauncher::DSL.new_world_block { model(:user) { string 'user_name' } } }

    it { should have(1).models }

    it 'user model should have user_name field' do
      expect(subject.models.first.fields.first).to eq(['string', 'user_name'])
    end
  end

  describe 'two models with has_one relationship' do
    subject(:world) do
      RailsLauncher::DSL.new_world_block do
        model(:user) { string 'user_name' }
        model(:blog) { string 'title' }
        user.has_one blog
      end
    end

    it { should have(2).models }
    specify 'user model should have one blog' do
      expect(model(:user).relations.first).to eq(['has_one', :blog])
    end

    specify 'blog model should belong to an user' do
      expect(model(:blog).relations.first).to eq(['belongs_to', :user])
    end

    def model(name)
      world.models.find { |m| m.name == name }
    end
  end
end
