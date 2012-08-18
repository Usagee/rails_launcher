require 'active_support'

module RailsLauncher
  module DSL
    def self.new_world(text)
      w = World.new
      w.instance_eval(text)
      w
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

        eigen_class = class << self; self; end
        eigen_class.instance_eval do
          plural_name = ActiveSupport::Inflector.pluralize(name).to_sym
          define_method(name) { m }
          define_method(plural_name) { m }
        end
      end
    end

    class Model
      attr_reader :name, :fields, :relations

      def initialize(name)
        @name = name
        @fields = []
        @relations = []
      end

      def string(name, opts = {})
        @fields << ['string', name]
      end

      # Add has_one relationship to the given model
      #
      def has_one(model)
        @relations << ['has_one', model.name]
        model.belongs_to(self)
      end

      # Add has_many relationship to the given model
      #
      def has_many(model)
        @relations << ['has_many', ActiveSupport::Inflector.pluralize(model.name).to_sym]
        model.belongs_to(self)
      end

      # Add belongs_to relationship
      # Do not use this function from DSL
      # called by other models
      #
      def belongs_to(model)
        @relations << ['belongs_to', model.name]
      end
    end
  end
end
