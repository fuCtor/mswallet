# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mswallet/version'

Gem::Specification.new do |spec|
  spec.name          = "mswallet"
  spec.version       = Mswallet::VERSION
  spec.authors       = ["ajieks@vmp.ru"]
  spec.email         = ["ajieks@vmp.ru"]
  spec.summary       = %q{Write a short summary. Required.}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'rack-test', [">= 0"]
  spec.add_development_dependency "simplecov"
  spec.add_dependency "libxml-ruby"
  spec.add_dependency "rack"
  spec.add_dependency(%q<rubyzip>, [">= 1.0.0"])


end
