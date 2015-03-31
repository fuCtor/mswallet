# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mswallet/version'

Gem::Specification.new do |spec|
  spec.name          = 'mswallet'
  spec.version       = Mswallet::VERSION
  spec.authors       = ['ajieks@vmp.ru']
  spec.email         = %w(ajieks@vmp.ru schalexe@gmail.com)
  spec.summary       = %q{A Windows Phone wallet pass generator.}
  spec.description   = %q{This gem allows you to create passes for Windows Phone Wallet. Unlike some, this works with Rails but does not require it.}
  spec.homepage      = 'http://github.com/fuCtor/mswallet'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test', ['>= 0']
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter', require: nil
  spec.add_dependency 'libxml-ruby'
  spec.add_dependency 'rack'
  spec.add_dependency('rubyzip', [">= 1.0.0"])

end
