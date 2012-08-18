require 'spec_helper'

describe RailsLauncher::DSL do
  describe 'world with single model' do
    subject(:world) { RailsLauncher::DSL.new_world_block { model(:user) { string 'user_name' } } }

    it { should have(1).models }

    it 'user model should have user_name field' do
      expect(subject.models.first.fields.first).to eq(['string', 'user_name'])
    end
  end
end
