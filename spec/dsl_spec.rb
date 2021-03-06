require 'spec_helper'

{ belong_to: 'belongs_to', have_one: 'has_one', have_many: 'has_many' }.each do |matcher, relation|
  RSpec::Matchers.define matcher do |expected, opts = {}|
    match do |actual|
      if opts.empty?
        actual.relations.include? [relation, expected]
      else
        actual.relations.include? [relation, expected, opts]
      end
    end
  end
end

RSpec::Matchers.define :have_field do |type, field|
  match do |actual|
    actual.fields.include? [type, field]
  end
end

describe RailsLauncher::DSL do
  describe 'world with single model' do
    subject(:world) { sample_world('simple') }

    it { should have(1).models }

    it 'user model should have user_name field' do
      expect(subject.models.first).to have_field 'string', 'user_name'
    end
  end

  describe 'two models with has_one relationship' do
    subject(:world) { sample_world('has_one') }

    it { should have(2).models }
    context('user') { specify { expect(model :user).to have_one :blog } }
    context('blog') { specify { expect(model :blog).to belong_to :user } }
  end

  describe 'two models with has_many relationship' do
    subject(:world) { sample_world('has_many') }

    context('user') { specify { expect(model :user).to have_many :posts } }
    context('post') { specify { expect(model :post).to belong_to :user } }
  end

  describe 'two models and a medium model for has_many_through' do
    subject(:world) { sample_world('has_many_through') }

    context 'user' do
      specify { expect(model :user).to have_many :comments }
      specify { expect(model :user).to have_many :posts, through: :comments }
    end

    context 'post' do
      specify { expect(model :post).to have_many :comments }
      specify { expect(model :post).to have_many :users, through: :comments }
    end
  end

  describe 'has_many without medium declaration' do
    subject(:world) { RailsLauncher::DSL.new_world %q{
model(:user) { string 'user_name' }
model(:post) { string 'title' }
user.has_many posts, through: :comments
} }

    context 'user' do
      specify { expect(model :user).to have_many :comments }
      specify { expect(model :user).to have_many :posts, through: :comments }
    end

    context 'comment' do
      specify { expect(model :comment).not_to be_nil }
      specify { expect(model :comment).not_to have_controller  }
    end
  end

  describe 'has_many_through with symbol when model is defined' do
    subject(:world) { RailsLauncher::DSL.new_world %q{
model(:user) { string 'user_name' }
model(:post) { string 'title' }
model(:comment) { string 'content' }
user.has_many posts, through: :comments
}}

    specify 'world should have one comment model with content field' do
      expect(world.models.select { |m| m.name == :comment }).to have(1).item
      expect(model :comment).to have_field ['string', 'content']
    end

    specify { expect(model :comment).to have_controller  }
  end

  describe 'overriding an automatically generated model' do
    subject(:world) { RailsLauncher::DSL.new_world %q{
model(:user) { string 'user_name' }
model(:post) { string 'title' }
user.has_many posts, through: :comments
model(:comment) { string 'content' }
}}

    specify 'world should have one comment model with content field' do
      expect(world.models.select { |m| m.name == :comment }).to have(1).item
      expect(model :comment).to have_field ['string', 'content']
    end
  end

  describe 'UsersController options' do
    let(:world) { RailsLauncher::DSL.new_world %Q{
model(:user) do
  #{definition}
end
}}
    subject(:controller) { model(:user).controller.options[:only] }

    context 'when only C and R are allowed' do
      let(:definition) { "controller only: [:index, :new, :create, :show]" }
      it { should include :index }
      it { should include :new }
      it { should include :create }
      it { should include :show }
      it { should_not include :update }
    end

    context 'except destroy' do
      let(:definition) { "controller except: [:destroy]" }
      it { should include :index }
      it { should_not include :destroy }
    end

    context 'only index, new and create, except index' do
      let(:definition) { "controller except: [:index], only: [:index, :new, :create]" }
      it { should include :new }
      it { should include :create }
      it { should_not include :index }
      it { should_not include :update }
    end
  end


  describe 'validation to a field of a model' do
    let(:world) { RailsLauncher::DSL.new_world %Q{
model(:user) do
  string :name
  string :email
  validates :name, presence: true
end
}}

    subject(:validation) { model(:user).validations.first }
    its(:code) { should == ":name, {:presence=>true}" }
  end

  describe 'integer field' do
    let(:world) { RailsLauncher::DSL.new_world %Q{
model(:user) { integer :age }
}}
    subject(:user) { model(:user) }
    it { should have_field ['integer', 'age'] }
  end

  describe 'text field' do
    let(:world) { RailsLauncher::DSL.new_world %Q{
model(:user) { text :age }
}}
    subject(:user) { model(:user) }
    it { should have_field ['text', 'age'] }
  end

  describe 'routing definition' do
    describe 'root' do
      let(:world) { RailsLauncher::DSL.new_world %Q{
routes { root :to => 'welcome#index' }
}}

      subject(:root) { world.route_definition.root }
      its(:code) { should == '{:to=>"welcome#index"}' }
    end

    describe 'match' do
      let(:world) { RailsLauncher::DSL.new_world %Q{
routes { match 'photos/:id' => 'photos#show' }
}}
      subject(:matches) { world.route_definition.matches }
      its('first.code') { should == '{"photos/:id"=>"photos#show"}' }
    end
  end

  describe 'a controller without a corresponding model' do
    describe 'controller' do
      let(:world) { RailsLauncher::DSL.new_world %Q{
controller :welcome, only: :index
 }}

      subject(:controller) { world.controllers.first }

      its(:name) { should == :welcome }
      it { subject.options[:only].should == [:index] }
    end
  end

  describe 'application name' do
    let(:world) { RailsLauncher::DSL.new_world %Q{
application 'test_application'
}}
    it { world.application_name.should == 'test_application' }
  end

  describe 'plugin' do
    subject(:world) do
      path = File.expand_path(File.join(__FILE__, '../../lib/rails_launcher/plugins/factory_girl.rb'))
      RailsLauncher::DSL.new_world %Q{plugin '#{path}'}
    end

    it { should have(1).plugins }
    its('plugins.first.class') { should == ::RailsLauncher::Plugin::FactoryGirl }
  end

  def model(name)
    world.find_model(name)
  end
end
