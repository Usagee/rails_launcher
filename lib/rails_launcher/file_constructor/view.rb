class RailsLauncher::FileConstructor
  class View < FileEntity
    # define views set for a controller without a model
    def self.no_model_controller(controller)
      controller.actions_with_view.map do |action|
        new(controller.name, action)
      end
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
  end
end
