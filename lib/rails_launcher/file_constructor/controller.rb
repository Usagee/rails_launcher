class RailsLauncher::FileConstructor
  class Controller < FileEntity
    def initialize(definition)
      @name = definition.name.to_s.pluralize
      @opts = definition.options
    end

    def path
      "app/controllers/#{controller_name}.rb"
    end

    def file_content
      erb = ERB.new(File.read template_path)
      erb.result binding
    end

    private

    def controller_name
      "#{@name}_controller"
    end

    def index_helper
      @name.pluralize
    end

    def plural
      @name.pluralize
    end

    def singular
      @name.singularize
    end

    def model
      @name.classify
    end

    def human_name
      @name.humanize
    end

    def find
      "@#{singular} = #{model}.find(params[:id])"
    end

    def template_path
      File.join(File.dirname(__FILE__), 'controller_template.rb.erb')
    end

    [ :index, :show, :new, :create, :edit, :update, :destroy ].each do |method|
      define_method("#{method}?") do
        return true unless @opts[:only]
        @opts[:only].include? method
      end
    end

    class NoModel < Controller
      def initialize(definition)
        super(definition)
        @name = definition.name.to_s
      end
      private
      def template_path
        File.join(File.dirname(__FILE__), 'no_model_controller_template.rb.erb')
      end
    end
  end
end
