module RailsLauncher
  class Validation
    def initialize(args)
      @args = args
    end

    # Generate a code for Rails' +validates+ from args.
    def code
      @args.map(&:inspect).join(", ")
    end
  end
end
