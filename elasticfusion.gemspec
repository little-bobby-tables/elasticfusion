$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'elasticfusion/version'
Gem::Specification.new do |spec|
  spec.name          = 'elasticfusion'
  spec.version       = Elasticfusion::VERSION
  spec.authors       = ['little-bobby-tables']
  spec.email         = ['little-bobby-tables@users.noreply.github.com']

  spec.summary       = 'elasticsearch-rails extensions'
  spec.homepage      = 'https://github.com/little-bobby-tables/elasticfusion'
  spec.license       = 'CC0-1.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rails', '>= 5.0'
  spec.add_runtime_dependency 'chronic'
  spec.add_runtime_dependency 'elasticsearch'
  spec.add_runtime_dependency 'elasticsearch-rails'
  spec.add_runtime_dependency 'elasticsearch-model'

  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
