require 'active_support'

module RailsLauncher
  class FileConstructor
    def initialize(world)
      @world = world
    end

    def models
      @world.models.map { |m| Model.new(m) }
    end

    def migrations
      @world.models.map { |m| Migration.new(m) }
    end

    class Model
      def initialize(model)
        @model = model
      end

      def to_s
        path
      end

      def path
        "app/models/#{@model.name}.rb"
      end

      def file_content
        <<RUBY
class #{ActiveSupport::Inflector.camelize @model.name}
  attr_accessor #{properties.map(&:inspect).join(', ')}
end
RUBY
      end

      private

      def properties
        @model.fields.map { |t| t[1].to_sym }
      end
    end

    class Migration
      @@migration_id = 0

      def initialize(model)
        @id = (@@migration_id += 1)
        @model = model
      end

      def to_s
        path
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
        ActiveSupport::Inflector.tableize(@model.name)
      end

      def class_table_name
        ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.classify(@model.name))
      end
    end
  end
end
