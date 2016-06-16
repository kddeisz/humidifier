# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'humidifier/version'

Gem::Specification.new do |spec|
  spec.name          = 'humidifier'
  spec.version       = Humidifier::VERSION
  spec.authors       = ['Localytics']
  spec.email         = ['oss@localytics.com']

  spec.summary       = 'CloudFormation made easy'
  spec.homepage      = 'https://github.com/localytics/humidifier'

  spec.files         = Dir['LICENSE', 'README.md', 'ext/**/*', 'lib/**/*', 'specs/**/*']
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/humidifier/extconf.rb']
  spec.required_ruby_version = '>= 2.1.8'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rubocop', '~> 0.39'
  spec.add_development_dependency 'rake-compiler', '~> 0.9.8'
  spec.add_development_dependency 'benchmark-ips', '~> 2.6.1'
end
