class RailsLauncher::FileConstructor
  class Routes < FileEntity
    attr_accessor :additional

    def initialize(definition, name)
      @definition = definition
      @name = name
      @additional = []
    end

    def path
      'config/routes.rb'
    end

    def file_content
      %Q{
#{application_class_name}::Application.routes.draw do
# No route to RESTful controllers is defined.
# It is recommended to use conventional routes (https://github.com/tkawa/conventional_routes)

#{root}
#{matches}
#{@additional.join("\n")}
end
}.lstrip
    end

    private

    def root
      if r = @definition.try(:root)
        "root #{r.code}\n"
      else
        ""
      end
    end

    def matches
      if @definition && @definition.matches
        @definition.matches.map { |m| "matches #{m.code}" }.join("\n")
      end
    end

    def application_class_name
      @name.classify
    end
  end
end
