require 'active_support'
require 'rails_launcher/dsl/routes'
require 'rails_launcher/dsl/model'
require 'rails_launcher/dsl/controller'

module RailsLauncher
  module DSL
    def self.new_world(text)
      w = World.new
      w.instance_eval(text)
      w
    end

    class World
      attr_reader :models, :route_definition, :controllers

      def initialize
        @models = []
        @controllers = []
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

      # Define routings
      # If there are two routes blocks, the latter completely overrides the former.
      #
      def routes(&block)
        routes = Routes.new
        routes.instance_eval(&block) if block_given?
        @route_definition = routes
      end

      # Define a model-free controller
      def controller(name, opts)
        @controllers << Controller.new(name, opts)
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
  end
end
