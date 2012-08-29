require 'rails_launcher/file_constructor/file_entity'
require 'rails_launcher/file_constructor/model'
require 'rails_launcher/file_constructor/migration'
require 'rails_launcher/file_constructor/controller'

module RailsLauncher
  class FileConstructor
    def initialize(world)
      @world = world
      @migration_id = 0
    end

    def file_entities
      models + migrations + controllers
    end

    private

    def models
      @world.models.map { |m| Model.new(m) }
    end

    def migrations
      @world.models.map { |m| Migration.new(m, @migration_id += 1) }
    end

    def controllers
      @world.models.select { |m| m.has_controller? }.map { |m| Controller.new(m.name, m.controller) }
    end
  end
end
