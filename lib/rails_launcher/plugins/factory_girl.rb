=begin rdoc
= Factory Girl Plugin

factory_girl[https://github.com/thoughtbot/factory_girl] plugin for rails_launcher.

This plugin creates factory files according to the model definitions.

For example, with this definition (which is in sample_worlds as has_many.rb)

    model(:user) { string 'user_name' }
    model(:post) { string 'title' }
    user.has_many posts

You get following two files.

+test/factories/users.rb+

    FactoryGirl.define do
      factory :user do
        name "TestString"
      end
    end

+test/factories/posts.rb+

    FactoryGirl.define do
      factory :post do
        title "TestString"
        user
      end
    end

== Configuration

- +root_path+: Path to place factory files, relative to the Rails root.
=end

module RailsLauncher::Plugin
  class FactoryGirl
    def initialize(options = {})
      @root_path = options[:root_path] || 'test/factories'
    end

    def process(world, files)
      files + factories(world)
    end

    def factories(world)
      world.models.map { |m| FactoryFile.new(@root_path, m) }
    end

    class FactoryFile < RailsLauncher::FileConstructor::FileEntity
      def initialize(root_path, model)
        @root_path, @model = root_path, model
      end

      def path
        "#{@root_path}/#{@model.name.to_s.tableize}.rb"
      end

      def file_content
        %Q{
FactoryGirl.define do
  factory :#{@model.name} do
#{attributes}
  end
end
}.lstrip
      end

      def attributes
        (fields + associations).map { |l| " " * 6 + l }.join("\n")
      end

      def fields
        @model.fields.map do |type, name|
          "#{name}#{default(type)}"
        end
      end

      def associations
        belonged_models(@model.relations)
      end

      def belonged_models(relations)
        relations.select { |type, model| type == 'belongs_to' }.map { |_, model| model.to_s }
      end

      def default(type)
        object = {
          'string'    => 'TestString',
          'text'      => 'TestText',
          'integer'   => 42,
          'float'     => 42.0,
          'decimal'   => 42,
          'datetime'  => "2012-01-01 00:00:00 +0000",
          'timestamp' => "2012-01-01 00:00:00 +0000",
          'time'      => '00:00:00 +0000',
          'date'      => '2012-01-01',
          'binary'    => 0,
          'boolean'   => false
        }[type]

        if object
          ' ' + object.inspect
        else
          ''
        end
      end
    end
  end
end
