require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class RailsLauncher::FileConstructor
  describe Controller do
    # workaround
    let(:controller) { described_class.new('test', opts) }

    context 'with no option' do
      let(:opts) { {} }
      subject { controller }

      its(:path) { should == 'app/controllers/tests_controller.rb' }

      describe :file_content do
        subject(:file_content) { controller.file_content }
        it { should include 'TestsController' }
        it { should include 'def index' }
        it { should include 'def new' }
        it { should include 'def create' }
        it { should include 'def edit' }
        it { should include 'def update' }
        it { should include 'def destroy' }
      end
    end

    context 'index only' do
      let(:opts) { { only: [:index] } }

      subject(:file_content) { controller.file_content }
      it { should include 'def index' }
      it { should_not include 'def show' }
    end
  end
end
