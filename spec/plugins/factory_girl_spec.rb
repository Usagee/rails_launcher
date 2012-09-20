require 'spec_helper'

module RailsLauncher
  describe 'FactoryGirl plugin' do
    describe 'one model' do
      let(:factory_girl_path) { File.expand_path(File.join(__FILE__, '../../../lib/rails_launcher/plugins/factory_girl.rb')) }
      let(:world) { RailsLauncher::DSL.new_world %Q{
plugin '#{factory_girl_path}'
model(:user) { string 'name' }
}}
      let(:constructor) { FileConstructor.new(world) }
      subject(:factory_file) { content_of_file('test/factories/users.rb') }

      it { should include 'factory :user' }
      it { should include 'name "TestString"' }
    end
  end
end
