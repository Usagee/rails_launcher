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
class #{@model.name.to_s.camelize}
  attr_accessible #{properties.map(&:inspect).join(', ')}
#{ relations }end
RUBY
      end

      private

      def properties
        @model.fields.map { |t| t[1].to_sym }
      end

      def relations
        opts = -> arg { arg ? arg.map { |k, v| ", #{k}: #{v.inspect}" }.join : '' }
        @model.relations.map { |r|
          '  ' + r[0] + ' ' + r[1].inspect + opts.call(r[2]) + "\n"
        }.join
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
#{ columns }
      t.timestamps
    end
#{ indices }  end
end
RUBY
      end

      private
      def table_name
        @model.name.to_s.tableize
      end

      def class_table_name
        @model.name.to_s.classify.pluralize
      end

      def columns
        base = @model.fields.map { |f| ' ' * 6 + "t.#{f[0]} :#{f[1]}" }.join "\n"

        base += belonging_relations.map { |rel| "\n      t.references :#{rel[1]}" }.join ''
      end

      def indices
        belonging_relations.map { |rel| "    add_index :#{table_name}, :#{rel[1]}_id\n" }.join ''
      end

      def belonging_relations
        @belonging_relations ||=
          @model.relations.select { |rel| rel[0] == 'belongs_to' }
      end
    end
  end
end
