require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module RailsLauncher
  describe FileConstructor::Routes do
    let(:routes) do
      route = DSL::Routes.new
      route.root to: 'welcome#index'
      route.match "login", to: "sessions#create"
      route
    end

    specify 'arguments of root has parenthesis' do
      content = described_class.new(routes, 'your_application_name').file_content
      content.should include 'root({:to=>"welcome#index"})'
    end

    specify 'application name ends with s' do
      content = described_class.new(routes, 'easy_sns').file_content
      content.should include 'EasySns::Application.routes'
    end

    specify 'arguments of match not necessarily parenthesis' do
      content = described_class.new(routes, 'your_application_name').file_content
      content.should include 'match "login", {:to=>"sessions#create"}'
    end
  end
end
