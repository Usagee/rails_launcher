=begin rdoc
= Devise Plugin

devise[https://github.com/plataformatec/devise] plugin for rails_launcher.

The name of model with authentication is fixed to User.

== Options

+authentication+ has following options

=== devise options

- :database_authenticatable
- :registerable
- :recoverable
- :rememberable
- :trackable
- :validatable
- :token_authenticatable
- :confirmable
- :lockable
- :timeoutable
- :omniauthable : takes a list of strategies you want to use (https://github.com/intridea/omniauth/wiki/List-of-Strategies)

This plugin generates a customized model and migration file according to these options.

=== global option

- +mailer_sender+: the e-mail address which will be shown in Devise::Mailer
                   default: "please-change-me-at-config-initializers-devise@example.com"

== Files

This plugin creates following files.

- app/controllers/users/omniauth_callbacks_controller.rb (if omniauthable)
- app/models/user.rb
- config/initializers/devise.rb
- config/locales/devise.en.yml
- config/locales/devise.ja.yml
- config/routes.rb
- db/migrate/xxx_devise_create_users.rb

== Usage

plugin 'devise.rb', database_authenticatable: true, registerable: true, omniauthable: [:twitter, :facebook]

=end

module RailsLauncher
  module Plugin
    class Devise
      FILES = lambda { |name| File.join(__FILE__, "../devise/#{name}") }

      def initialize(options = {})
        @options = options
      end

      def process(world, files, migration_id_generator)
        @migration_id_generator = migration_id_generator
        model(route(files)) + static_files + initializer
      end

      def static_files
        [Locale.new(:ja), Locale.new(:en)]
      end

      def route(files)
        routes_rb = files.find { |f| f.path == 'config/routes.rb' }
        routes_rb.additional << 'devise_for :users'
        files
      end

      def model(files)
        if files.find { |f| f.path == 'app/models/user.rb' }
          files
        else
          files << UserModel.new(@options) << UserMigration.new(@migration_id_generator, @options)
        end
      end

      def initializer
        file = FileConstructor::FileEntity.new
        class << file
          def path
            "config/initializers/devise.rb"
          end

          def file_content
            ERB.new(File.read(FILES.call("initializer.rb.erb"))).result binding
          end
        end
        [file]
      end

      class Locale < FileConstructor::FileEntity
        def initialize(locale)
          @locale = locale
        end

        def path
          "config/locales/devise.#{@locale}.yml"
        end

        def file_content
          File.read(FILES.call("locale.#{@locale}.yml"))
        end
      end

      class UserModel < FileConstructor::FileEntity
        def initialize(options)
          @options = options
        end

        def path
          'app/models/user.rb'
        end

        def modules
          @options.keys.map { |key| key.to_sym.inspect }.join(", ")
        end

        def omniauth_method
          if @options[:omniauthable]
            %Q{def self.find_for_oauth(auth, sign_in_resource = nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(email: auth.info.email || '', password:Devise.friendly_token[0,20]) do |u|
        u.provider = auth.provider
        u.uid      = auth.uid
      end
    end
    user
  end}
          end
        end

        def file_content
            %Q{
class User < ActiveRecord::Base
  devise #{modules}
  attr_accessible :email, :password, :password_confirmation

  #{omniauth_method}
end
}
        end
      end

      class UserMigration < FileConstructor::FileEntity
        def initialize(migration_id_generator, options)
          @id = migration_id_generator.next
          @options = options
        end

        def path
          "db/migrate/#{@id}_devise_create_users.rb"
        end

        def modules
          @options.keys.map { |key| key.to_sym.inspect }.join(", ")
        end

        def file_content
            %Q{
class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :email, :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""
    end

    add_index :users, :email, :unique => true
  end
end
}
        end
      end
    end
  end
end
