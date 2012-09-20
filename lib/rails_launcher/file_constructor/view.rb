class RailsLauncher::FileConstructor
  class View < FileEntity
    # define views set for a controller without a model
    def self.no_model_controller(controller)
      controller.actions_with_view.map do |action|
        new(controller.name, action)
      end
    end

    # define views set for a controller a model
    def self.model_controller(model, controller)
      actions = controller.actions_with_view
      if actions.include?(:new) || actions.include?(:edit)
        form = ModelView.new(model, controller.name, '_form')
      end
      action_views = actions.map do |action|
        ModelView.new(model, controller.name, action)
      end
      action_views << form
    end

    def initialize(controller, action)
      @controller, @action = controller, action
    end

    def path
      "app/views/#{@controller}/#{@action}.html.haml"
    end

    def file_content
      "%h1 #{@controller}##{@action}"
    end

    class ModelView < View
      def initialize(model, controller, action)
        @model, @controller, @action = model, controller, action
      end

      def file_content
        erb = ERB.new(File.read(template_path), nil, '-')
        erb.result binding
      end

      def human_name
        @model.name.to_s.humanize
      end

      def plural_table_name
        @model.table_name
      end

      def singular_table_name
        @model.name.to_s.singularize
      end

      def attributes
        @model.fields.map { |type, name| name }
      end

      def index_helper
        plural_table_name
      end

      def template_path
        File.join(File.dirname(__FILE__), "view_templates/#{@action}.html.haml.erb")
      end
    end
  end
end
