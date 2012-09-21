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
      FILES = lambda { |name| File.join(File.dirname(__FILE__), "devise", name) }

      def initialize(options = {})
        @options = Option.new(options)
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
        [Initializer.new(@options)]
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

      class Option
        def initialize(hash)
          @hash = hash
        end

        [:database_authenticatable, :registerable, :recoverable, :rememberable,
          :trackable, :validatable, :token_authenticatable, :confirmable,
          :lockable, :timeoutable, :omniauthable].each do |mod|
            define_method("#{mod}?") { !! @hash[mod] }
        end

        def modules
          @hash.keys
          [:database_authenticatable, :registerable, :recoverable, :rememberable,
          :trackable, :validatable, :token_authenticatable, :confirmable,
          :lockable, :timeoutable, :omniauthable] & @hash.keys
        end

        def omniauth_providers
          @hash[:omniauthable] || []
        end

        def mailer_sender
          @hash[:mailer_sender] || "please-change-me-at-config-initializers-devise@example.com"
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
          @options.modules.map(&:inspect).join(", ")
        end

        def omniauth_method
          if @options.omniauthable?
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

        def accessible_columns
          columns = []
          if @options.database_authenticatable?
            columns += [:email, :password, :password_confirmation]
          end

          if @options.rememberable?
            columns += [:remember_me]
          end

          columns.map(&:inspect).join(", ")
        end

        def file_content
            %Q{
class User < ActiveRecord::Base
  devise #{modules}
  attr_accessible #{accessible_columns}

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

        def columns
          columns = []
          if @options.database_authenticatable?
            columns << 't.string :email, :null => false, :default => ""'
            columns << 't.string :encrypted_password, :null => false, :default => ""'
          end

          if @options.recoverable?
            columns << 't.string   :reset_password_token'
            columns << 't.datetime :reset_password_sent_at'
          end

          if @options.rememberable?
            columns << 't.datetime :remember_created_at'
          end

          if @options.trackable?
            columns << 't.integer  :sign_in_count, :default => 0'
            columns << 't.datetime :current_sign_in_at'
            columns << 't.datetime :last_sign_in_at'
            columns << 't.string   :current_sign_in_ip'
            columns << 't.string   :last_sign_in_ip'
          end

          if @options.confirmable?
            columns << 't.string   :confirmation_token'
            columns << 't.datetime :confirmed_at'
            columns << 't.datetime :confirmation_sent_at'
            columns << 't.string   :unconfirmed_email # Only if using reconfirmable'
          end

          if @options.lockable?
            columns << 't.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts'
            columns << 't.string   :unlock_token # Only if unlock strategy is :email or :both'
            columns << 't.datetime :locked_at'
          end

          if @options.token_authenticatable?
            columns << 't.string :authentication_token'
          end

          if @options.omniauthable?
            columns << 't.string :provider'
            columns << 't.string :uid'
          end
          columns
        end

        def indices
          indices = []

          if @options.database_authenticatable?
            indices << 'add_index :users, :email, :unique => true'
          end

          if @options.recoverable?
            indices << 'add_index :users, :reset_password_token, :unique => true'
          end

          if @options.confirmable?
            indices << 'add_index :users, :confirmation_token, :unique => true'
          end

          if @options.lockable?
            indices << 'add_index :users, :unlock_token, :unique => true'
          end

          if @options.token_authenticatable?
            indices << 'add_index :users, :authentication_token, :unique => true'
          end

          if @options.omniauthable?
            indices << 'add_index :users, :uid, :unique => true'
          end
          indices
        end

        def indent(lines, depth)
          lines.map{ |l| ' ' * depth + l }.join("\n")
        end

        def file_content
            %Q{
class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
#{indent(columns, 6)}

      t.timestamp
    end

#{indent(indices, 4)}
  end
end
}
        end
      end

      class Initializer < FileConstructor::FileEntity
        def initialize(options)
          @options = options
        end

        def path
          "config/initializers/devise.rb"
        end

        def file_content
          ERB.new(File.read(FILES.call("initializer.rb.erb"))).result binding
        end

        def requirements
          @options.omniauth_providers.map { |provider|
            %Q{require "omniauth-#{provider}"}
          }.join("\n")
        end

        def additional_configs
          @options.omniauth_providers.map { |provider|
            %Q{config.omniauth :#{provider}, ENV['#{provider.upcase}_KEY'], ENV['#{provider.upcase}_SECRET']}
          }.join("\n  ")
        end

        def mailer_sender
          @options.mailer_sender
        end
      end
    end
  end
end
