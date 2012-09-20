module RailsLauncher
  module DSL
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
        @controller = Controller.new(plural_symbol, {}, self)
        @validations = []
      end

      # fields
      # Fields are for define database table columns.
      # These methods are which Rails' +TableDefinition+ accepts.
      [:primary_key, :string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean].each do |key|
        define_method(key) do |name|
          @fields << [key.to_s, name.to_s]
        end
      end

      def plural_symbol
        name.to_s.pluralize.to_sym
      end

      def table_name
        name.to_s.tableize
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
        @controller = Controller.new(plural_symbol, opts, self)
      end

      # Add validation
      # This method accepts the same format as Rails ActiveModel's +validates+.
      # All arguments are pasted into a generated model as it is.
      def validates(*args)
        @validations << Validation.new(args)
      end

      protected
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
    end
  end
end
