require 'rails_launcher/file_constructor/file_entity'
require 'rails_launcher/file_constructor/model'
require 'rails_launcher/file_constructor/migration'
require 'rails_launcher/file_constructor/controller'
require 'rails_launcher/file_constructor/routes'
require 'rails_launcher/file_constructor/view'

module RailsLauncher
  class FileConstructor
    def initialize(world)
      @world = world
      @migration_id = 0
    end

    def file_entities
      @world.plugins.reduce(core_file_entities) do |files, plugin|
        plugin.process(@world, files)
      end
    end

    def core_file_entities
      models + migrations + controllers + views + routes_rb
    end

    private

    def models
      @world.models.map { |m| Model.new(m) }
    end

    def migrations
      @world.models.map { |m| Migration.new(m, @migration_id += 1) }
    end

    def controllers
      @world.models.map { |m| m.has_controller? ? Controller.new(m.controller) : nil }.compact +
        @world.controllers.map { |c| Controller::NoModel.new(c) }
    end

    def routes_rb
      if @world.route_definition
        [Routes.new(@world.route_definition, @world.application_name)]
      else
        []
      end
    end

    def views
      @world.controllers.map { |c| View.no_model_controller(c) }.flatten +
        @world.models.map { |m| m.has_controller? ? View.model_controller(m, m.controller) : nil }.flatten.compact
    end
  end
end
