# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'liquid_lint/constants'
require 'liquid_lint/version'

Gem::Specification.new do |s|
  s.name             = 'liquid_lint'
  s.version          = LiquidLint::VERSION
  s.license          = 'MIT'
  s.summary          = 'Liquid template linting tool'
  s.description      = 'Configurable tool for writing clean and consistent Liquid templates'
  s.authors          = ['zeusintuivo']
  s.email            = ['zeus@intuivo.com']
  s.homepage         = LiquidLint::REPO_URL

  s.require_paths    = ['lib']

  s.executables      = ['liquid-lint']

  s.files            = Dir['config/**.yml'] +
                       Dir['lib/**/*.rb'] +
                       ['LICENSE.md']

  s.required_ruby_version = '>= 2.4.0'

  s.add_runtime_dependency 'rubocop', ['>= 1.0', '< 2.0']
  s.add_runtime_dependency 'liquid', ['>= 3.0', '< 6.0']

  s.add_development_dependency 'pry', '~> 0.13'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its', '~> 1.0'
end
