# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails_launcher/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["tomykaira"]
  gem.email         = ["tomykaira@gmail.com"]
  gem.description   = %q{Rich setup tool for rails projects}
  gem.summary       = %q{Rich setup tool for rails projects}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rails_launcher"
  gem.require_paths = ["lib"]
  gem.version       = RailsLauncher::VERSION

  gem.add_dependency 'activesupport'
  gem.add_development_dependency 'rspec', '~> 2.11.0'
end
