require 'spec_helper'

RSpec::Matchers.define :create_file do |expected|
  match do |actual|
    actual.file_entities.any? { |f| f.path.match expected }
  end
end

module RailsLauncher
  describe 'Devise plugin' do
    let(:devise_path) { File.expand_path(File.join(__FILE__, '../../../lib/rails_launcher/plugins/devise.rb')) }
    let(:constructor) { FileConstructor.new(world) }

    describe 'common files' do
      let(:world) { DSL.new_world %Q{
plugin '#{ devise_path }', database_authenticatable: true
}}
      subject { constructor }

      it { should create_file 'config/initializers/devise.rb' }
      it { should create_file 'config/locales/devise.ja.yml' }
      it { should create_file 'config/locales/devise.en.yml' }
    end

    describe 'database_authenticatable' do
      let(:world) { DSL.new_world %Q{
plugin '#{ devise_path }', database_authenticatable: true
}}

      describe 'app/models/user.rb' do
        subject(:file) { content_of_file('app/models/user.rb') }
        it { should match_line 'devise :database_authenticatable' }
      end

      describe 'config/routes.rb' do
        subject(:file) { content_of_file('config/routes.rb') }
        it { should match_line 'devise_for :users' }
      end

      describe 'db/migrate/xxx_devise_create_users.rb' do
        subject(:file) { content_of_file('db/migrate/\d*_devise_create_users.rb') }
        it { should match_line 't.string :email, :null => false, :default => ""' }
        it { should match_line 't.string :encrypted_password, :null => false, :default => ""' }
        it { should match_line 'add_index :users, :email, :unique => true' }
        it { should_not match_line 't.datetime :remember_created_at'  }
      end
    end

    describe 'omniauthable with twitter and facebook' do
      let(:world) { DSL.new_world %Q{
plugin '#{ devise_path }', database_authenticatable: true, omniauthable: [:twitter, :facebook]
}}

      describe 'app/models/user.rb' do
        subject(:file) { content_of_file('app/models/user.rb') }
        it { should include ':omniauthable' }
        it { should include 'def self.find_for_oauth(auth, sign_in_resource = nil)' }
      end

      describe 'db/migrate/xxx_devise_create_users.rb' do
        subject(:file) { content_of_file('db/migrate/\d*_devise_create_users.rb') }
        it { should match_line 't.string :provider' }
        it { should match_line 't.string :uid' }
      end
    end
  end
end
