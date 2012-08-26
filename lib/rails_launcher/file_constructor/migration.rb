class RailsLauncher::FileConstructor
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
