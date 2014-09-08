# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'errbit_redmine_plugin/version'

Gem::Specification.new do |spec|
  spec.name          = "errbit_redmine_plugin"
  spec.version       = ErrbitRedminePlugin::VERSION
  spec.authors       = ["Stephen Crosby"]
  spec.email         = ["stevecrozz@gmail.com"]
  spec.description   = %q{Redmine integration for Errbit}
  spec.summary       = %q{Redmine integration for Errbit}
  spec.homepage      = "https://github.com/brandedcrate/errbit_redmine_plugin"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'errbit_plugin', '~> 0'
  spec.add_runtime_dependency 'oruen_redmine_client', '~> 0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 0'
end
