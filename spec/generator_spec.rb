require 'spec_helper'
require 'tmpdir'

describe RailsLauncher::Generator do
  let(:simple_world_path) { sample_path('simple') }
  let(:tempdir) { Dir.mktmpdir }

  before do
    @pwd = Dir.pwd
    Dir.chdir tempdir
  end

  after { Dir.chdir @pwd }

  it 'should create files from world defined by DSL' do
    described_class.new(simple_world_path).generate_files(tempdir)
    files = Dir.glob("**/*")

    expect(files).to include 'app/models/user.rb'
    expect(files).to include 'db/migrate/001_create_users.rb'
    expect(files).to include 'app/controllers/users_controller.rb'
  end
end
