module RailsLauncher
  module DSL
    class Controller
      attr_reader :name, :options

      def initialize(name, options = {}, model = nil)
        @name, @options = name, normalize(options)
      end

      def normalize(options)
        # +include+ is required in FileConstructor::Controller
        options[:only] = wrap_array(options[:only])
        options[:except] = wrap_array(options[:except])
        if options[:except]
          rest_methods = [:index, :show, :new, :create, :edit, :update, :destroy] - options[:except]
          options[:only] = options[:only] ? options[:only] & rest_methods : rest_methods
        end
        options
      end

      def wrap_array(object)
        if object.respond_to?(:include?)
          object
        elsif object.nil?
          nil
        else
          [object]
        end
      end
    end
  end
end
