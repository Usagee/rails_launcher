require 'spec_helper'

RSpec::Matchers.define :create_file do |expected|
  match do |actual|
    actual.file_entities.any? { |f| f.path.match expected }
  end
end

RSpec::Matchers.define :include_in_line do |*expected|
  match do |actual|
    actual.split("\n").any? { |line| expected.all? { |token| line.include? token } }
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
        it { should match_line 'add_index :users, :uid' }
      end

      describe 'config/initializers/devise.rb' do
        subject(:file) { content_of_file('config/initializers/devise.rb') }
        it { should match_line 'require "omniauth-twitter"' }
        it { should match_line 'require "omniauth-facebook"' }

        it { should include %q{config.omniauth :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']} }
        it { should include %q{config.omniauth :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']} }
      end

      describe 'config/routes.rb' do
        subject(:file) { content_of_file('config/routes.rb') }

        it { should include_in_line 'devise_for', ':omniauth_callbacks => "users/omniauth_callbacks"' }
      end

      describe 'app/controllers/users/omniauth_callbacks_conroller.rb' do
        subject(:file) { content_of_file('app/controllers/users/omniauth_callbacks_conroller.rb') }

        it { should include 'class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController' }
        it { should include 'def twitter' }
        it { should include 'def facebook' }
        it { should include 'User.find_for_oauth' }
        it { should include 'flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"' }
      end
    end

    describe 'mailer_sender config in initializer' do
      let(:world) { DSL.new_world %Q{
plugin '#{ devise_path }', database_authenticatable: true, mailer_sender: 'hello@example.com'
}}

      subject(:initializer) { content_of_file('config/initializers/devise.rb') }

      it { should include 'hello@example.com' }
      it { should_not include "please-change-me-at-config-initializers-devise@example.com" }
    end

    describe 'remember me' do
      let(:world) { DSL.new_world %Q{
plugin '#{ devise_path }', database_authenticatable: true, rememberable: true
}}

      describe 'app/models/user.rb' do
        subject(:file) { content_of_file('app/models/user.rb') }
        it { should include_in_line 'attr_accessible', ':remember_me' }
      end

      describe 'db/migrate/xxx_devise_create_users.rb' do
        subject(:file) { content_of_file('db/migrate/\d*_devise_create_users.rb') }
        it { should match_line 't.datetime :remember_created_at' }
      end
    end

    context 'when User model is defined using DSL' do
      let(:world) { DSL.new_world %Q{
plugin '#{ devise_path }', database_authenticatable: true
model(:user) { string :nickname }
}}

      describe 'app/models/user.rb' do
        subject(:file) { content_of_file('app/models/user.rb') }
        it { should include_in_line 'attr_accessible', ':nickname', ':email' }
      end
    end
  end
end
