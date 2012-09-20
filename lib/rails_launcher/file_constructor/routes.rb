class RailsLauncher::FileConstructor
  class Routes < FileEntity
    def initialize(definition)
      @definition = definition
    end

    def path
      'config/routes.rb'
    end

    def file_content
      %Q{
YOUR_APPLICATION_NAME::Application.routes.draw do
#{root}
#{matches}
end
}.lstrip
    end

    private

    def root
      if r = @definition.root
        "root #{r.code}\n"
      else
        ""
      end
    end

    def matches
      @definition.matches.map { |m| "matches #{m.code}" }.join("\n")
    end
  end
end
