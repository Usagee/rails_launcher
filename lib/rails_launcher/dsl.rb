module RailsLauncher
  module DSL
    def self.new_world
      World.new
    end

    class World
      attr_reader :models

      def initialize
        @models = []
      end

      def model(name, &block)
        m = Model.new(name)
        m.instance_eval(&block)
        @models << m
      end
    end

    class Model
      attr_reader :name, :fields

      def initialize(name)
        @name = name
        @fields = []
      end

      def string(name, opts = {})
        @fields << ['string', name]
      end
    end
  end
end