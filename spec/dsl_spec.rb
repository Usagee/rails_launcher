require 'spec_helper'

describe RailsLauncher::DSL do
  describe 'world with single model' do
    subject do
      RailsLauncher::DSL.new_world.instance_eval do
        model(:user) { string 'user_name' }
      end
    end

    it { should have(1).model }

    it 'user model should have user_name field' do
      expect(subject.models.first.fields.name).to eq('user_name')
    end
  end
end
