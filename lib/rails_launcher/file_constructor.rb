require 'active_support'

module RailsLauncher
  class FileConstructor
    def initialize(world)
      @world = world
      @migration_id = 0
    end

    def file_entities
      models + migrations
    end

    private

    def models
      @world.models.map { |m| Model.new(m) }
    end

    def migrations
      @world.models.map { |m| Migration.new(m, @migration_id += 1) }
    end

    class FileEntity
      def to_s
        path
      end

      # Relative path to rails root.
      # Every subclass should implement this method.
      #
      def path
        raise NotImplementedError
      end

      # File content in String
      # Every subclass should implement this method.
      #
      def file_content
        raise NotImplementedError
      end

      private
       # Shortcut for ActiveSupport::Inflector, useful for name construction
      Infl = ActiveSupport::Inflector
   end

    class Model < FileEntity
      def initialize(model)
        @model = model
      end

      def path
        "app/models/#{@model.name}.rb"
      end

      def file_content
        <<RUBY
class #{Infl.camelize @model.name}
  attr_accessor #{properties.map(&:inspect).join(', ')}
end
RUBY
      end

      private

      def properties
        @model.fields.map { |t| t[1].to_sym }
      end
    end

    class Migration < FileEntity
      def initialize(model, id)
        @model, @id = model, id
      end

      def path
        "db/migrate/%03d_create_%s.rb" % [@id, table_name]
      end

      def file_content
        <<RUBY
class Create#{class_table_name} < ActiveRecord::Migration
  def change
    create_table :#{table_name} do |t|
      t.string :user_name
      t.timestamps
    end
  end
end
RUBY
      end

      private
      def table_name
        Infl.tableize(@model.name)
      end

      def class_table_name
        Infl.pluralize(Infl.classify(@model.name))
      end
    end
  end
end
