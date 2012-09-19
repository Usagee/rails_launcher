require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module RailsLauncher
  describe FileConstructor::Model do
    let(:model) do
      model = DSL::Model.new(:user, :world_not_used)
      model.string :name
      model.validates :name, presence: true
      model
    end

    subject(:model_file) { described_class.new(model).file_content }

    # assert name presence validation
    it { should match /validates\s+:name,.*:presence/ }
  end
end
