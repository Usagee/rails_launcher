require 'spec_helper'

module RailsLauncher
  describe Validation do
    describe 'one attribute for a field' do
      subject(:validation) { described_class.new([:name, {:presence => true}]) }

      its(:code) { should == ':name, {:presence=>true}' }
    end

    describe 'one attribute for 2 fields' do
      subject(:validation) { described_class.new([:name, :email, :presence => true]) }

      its(:code) { should == ':name, :email, {:presence=>true}' }
    end

    describe '2 attributes for 2 fields' do
      subject(:validation) { described_class.new([:name, :email, :presence => true, :length => { :maximum => 255 }]) }

      its(:code) { should == ':name, :email, {:presence=>true, :length=>{:maximum=>255}}' }
    end
  end
end
