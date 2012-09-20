module RailsLauncher
  module DSL
    class Routes
      attr_reader :matches

      def initialize
        @matches = []
      end

      # Define an action routed to /
      def root(action = nil)
        if action
          @root = Route::Root.new(action)
        else
          @root
        end
      end

      # Add a rails +match+ routing
      def match(*options)
        @matches << Route.new(options)
      end
    end
  end
end
