module RailsLauncher
  class Generator
    def initialize(definition_path)
      @w = DSL.new_world
      @w.instance_eval(File.read definition_path)
    end

    def generate_files(topdir)
      FileConstructor.new(@w).file_entities.each do |entity|
        path = File.join(topdir, entity.path)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w') { |f| f.write entity.file_content }
      end
    end
  end
end
