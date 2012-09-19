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

      # Define new model
      # If block given, that is evaluated in the context of a new model.
      # If a model exists with the same name, that is returned.
      #
      def model(a_name, &block)
        name = a_name.to_s.singularize.to_sym
        if m = find_model(name)
          m.instance_eval &block if block_given?
          return m
        end
        new_model(name, &block)
      end

      # Resolve symbol to an actual model instance
      # If a corresponding model does not exists, it is created.
      # Created model does not have a controller
      #
      def resolve_model(a_name)
        name = a_name.to_s.singularize.to_sym
        if m = find_model(name)
          return m
        end
        model(name) { no_controller }
      end

      # Find existing model
      #
      def find_model(name)
        models.find { |m| m.name == name }
      end

      private
      def new_model(name, &block)
        m = Model.new(name, self)
        m.instance_eval(&block) if block_given?
        @models << m

        eigen_class = class << self; self; end
        eigen_class.instance_eval do
          define_method(name) { m }
          define_method(m.plural_symbol) { m }
        end
        m
      end
    end

    class Model
      attr_reader :name, :fields, :relations, :validations

      def has_controller?
        !! controller
      end

      def initialize(name, world)
        @name = name
        @world = world
        @fields = []
        @relations = []
        @controller = {}
        @validations = []
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
          medium = if opts[:through].respond_to?(:belongs_to)
                     opts[:through]
                   else
                     m = @world.resolve_model(opts[:through])
                   end
          self.has_many_through(model, medium)
          model.has_many_through(self, medium)
        else
          @relations << ['has_many', model.plural_symbol]
          model.belongs_to(self)
        end
      end

      # Specify that this model has no controller
      def no_controller
        @controller = nil
      end

      def controller(opts = nil)
          return @controller if opts == nil
          @controller = optimize_opts(opts)
      end

      # Add validation
      # This method accepts the same format as Rails ActiveModel's +validates+.
      # All arguments are pasted into a generated model as it is.
      def validates(*args)
        @validations << Validation.new(args)
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
        has_many(medium)
        @relations << ['has_many', other.plural_symbol, through: medium.plural_symbol]
      end

      private

      def optimize_opts(opts)
        if opts[:except]
          rest_methods = [:index, :show, :new, :create, :edit, :update, :destroy] - opts[:except]
          opts[:only] = opts[:only] ? opts[:only] & rest_methods : rest_methods
        end
        opts
      end
    end
  end
end
