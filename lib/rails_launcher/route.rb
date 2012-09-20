module RailsLauncher

  # +match+ definition in routes.rb
  class Route

    def initialize(options)
      @options = options
    end

    def code
      @options.map(&:inspect).join(", ")
    end

    # Special class for root definition
    # In Rails, +root+ is internally +match+ for '/', and the launcher can
    # explode.  However, +root+ is easy to read in routes.rb.
    class Root
      def initialize(options)
        @options = options
      end

      def code
        @options.inspect
      end
    end
  end
end
