require 'spec_helper'

describe RailsLauncher::FileConstructor do
  let(:simple_world) do
    w = RailsLauncher::DSL.new_world
    w.instance_eval { model(:user) { string 'user_name' } }
    w
  end

  describe 'files for the simple world' do
    subject(:constructor) { described_class.new(simple_world) }

    its('models.first.path') { should == 'app/models/user.rb' }

    it 'should create User model file' do
      constructor.models.first.to_s.should eq <<RUBY
class User
  attr_accessor :user_name
end
RUBY
    end
  end
end
