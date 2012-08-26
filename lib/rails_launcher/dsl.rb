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
          define_method(name) { m }
          define_method(m.plural_symbol) { m }
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

      def plural_symbol
        name.to_s.pluralize.to_sym
      end

      # Add has_one relationship to the given model
      #
      def has_one(model)
        @relations << ['has_one', model.name]
        model.belongs_to(self)
      end

      # Add has_many relationship to the given model
      #
      def has_many(model, opts = {})
        if opts[:through]
          self.has_many_through(model, opts[:through])
          model.has_many_through(self, opts[:through])
        else
          @relations << ['has_many', model.plural_symbol]
          model.belongs_to(self)
        end
      end

      # Add belongs_to relationship
      # Do not use this function from DSL
      # called by other models
      #
      def belongs_to(model)
        @relations << ['belongs_to', model.name]
      end

      # Add has_many :through relationsip
      # Do not use this function from DSL
      # called by other models
      #
      def has_many_through(other, medium)
          @relations << ['has_many', medium.plural_symbol]
          @relations << ['has_many', other.plural_symbol, through: medium.plural_symbol]
          medium.belongs_to(self)
      end
    end
  end
end
