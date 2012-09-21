require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module RailsLauncher
  describe FileConstructor::Routes do
    let(:routes) do
      route = DSL::Routes.new
      route.root to: 'welcome#index'
      route
    end

    describe 'arguments of root has parenthesis' do
      subject(:model_file) { described_class.new(routes, 'your_application_name').file_content }
      it { should include 'root({:to=>"welcome#index"})' }
    end

    describe 'application name ends with s' do
      subject(:model_file) { described_class.new(routes, 'easy_sns').file_content }
      it { should include 'EasySns::Application.routes' }
    end
  end
end
