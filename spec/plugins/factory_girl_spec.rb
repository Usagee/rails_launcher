require 'spec_helper'

module RailsLauncher
  describe 'FactoryGirl plugin' do
    let(:factory_girl_path) { File.expand_path(File.join(__FILE__, '../../../lib/rails_launcher/plugins/factory_girl.rb')) }
    let(:constructor) { FileConstructor.new(world) }

    describe 'one model' do
      let(:world) { RailsLauncher::DSL.new_world %Q{
plugin '#{factory_girl_path}'
model(:user) { string 'name' }
}}
      subject(:factory_file) { content_of_file('test/factories/users.rb') }

      it { should include 'factory :user' }
      it { should include 'name "TestString"' }
    end

    describe 'factory file for a belonging model when there is a relation' do
      let(:world) { RailsLauncher::DSL.new_world %Q{
plugin '#{factory_girl_path}'
model(:user) { string 'name' }
model(:post) { string 'title' }
user.has_many posts
}}

      subject(:post_factory) { content_of_file('test/factories/posts.rb') }

      it { should include 'factory :post' }
      it { should match '^\s*user$' }
    end
  end
end
