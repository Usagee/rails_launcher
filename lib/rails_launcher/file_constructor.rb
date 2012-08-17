require 'active_support'

module RailsLauncher
  class FileConstructor
    def initialize(world)
      @world = world
    end

    def models
      @world.models.map { |m| Model.new(m) }
    end

    class Model
      def initialize(model)
        @model = model
      end

      def to_s
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
  end
end
