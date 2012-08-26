class RailsLauncher::FileConstructor
  class Model < FileEntity
    def initialize(model)
      @model = model
    end

    def path
      "app/models/#{@model.name}.rb"
    end

    def file_content
      <<RUBY
class #{@model.name.to_s.camelize} < ActiveRecord::Base
  attr_accessible #{properties.map(&:inspect).join(', ')}
#{ relations }end
RUBY
    end

    private

    def properties
      @model.fields.map { |t| t[1].to_sym }
    end

    def relations
      opts = -> arg { arg ? arg.map { |k, v| ", #{k}: #{v.inspect}" }.join : '' }
      @model.relations.map { |r|
        '  ' + r[0] + ' ' + r[1].inspect + opts.call(r[2]) + "\n"
      }.join
    end
  end
end
