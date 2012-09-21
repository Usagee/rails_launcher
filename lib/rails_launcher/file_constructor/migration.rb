class RailsLauncher::FileConstructor
  class Migration < FileEntity
    def initialize(model, id)
      @model, @id = model, id
    end

    def path
      "db/migrate/%03d_create_%s.rb" % [@id.next, @model.table_name]
    end

    def file_content
      <<RUBY
class Create#{class_table_name} < ActiveRecord::Migration
  def change
    create_table :#{@model.table_name} do |t|
#{ indent(columns, 6) }
      t.timestamps
    end
#{ indent(indices, 4) }
  end
end
RUBY
    end

    private
    def class_table_name
      @model.name.to_s.classify.pluralize
    end

    def indent(lines, depth)
      lines.map{ |l| ' ' * depth + l }.join("\n")
    end

    def columns
      @model.fields.map { |f| "t.#{f[0]} :#{f[1]}" } +
        belonging_relations.map { |rel| "t.references :#{rel[1]}" }
    end

    def indices
      belonging_relations.map { |rel| "add_index :#{@model.table_name}, :#{rel[1]}_id" }
    end

    def belonging_relations
      @belonging_relations ||=
        @model.relations.select { |rel| rel[0] == 'belongs_to' }
    end
  end
end
