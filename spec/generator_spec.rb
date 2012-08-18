require 'spec_helper'
require 'tmpdir'

describe RailsLauncher::Generator do
  let(:simple_world_path) { File.expand_path('../sample_worlds/simple.rb', __FILE__) }
  let(:tempdir) { Dir.mktmpdir }

  before do
    @pwd = Dir.pwd
    Dir.chdir tempdir
  end

  after { Dir.chdir @pwd }

  it 'should create files from world defined by DSL' do
    described_class.new(simple_world_path).generate_files(tempdir)
    files = Dir.glob("**/*")

    files.should include 'app/models/user.rb'
    files.should include 'db/migrate/001_create_users.rb'
  end
end
