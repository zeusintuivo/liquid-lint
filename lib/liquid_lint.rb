# frozen_string_literal: true

# Load all liquid-lint modules necessary to parse and lint a file.
# Ordering here can be important depending on class references in each module.

# Need to load liquid before we can reference some classes or define filters
require 'liquid'

require 'liquid_lint/constants'
require 'liquid_lint/exceptions'
require 'liquid_lint/configuration'
require 'liquid_lint/configuration_loader'
require 'liquid_lint/utils'
require 'liquid_lint/atom'
require 'liquid_lint/sexp'
require 'liquid_lint/file_finder'
require 'liquid_lint/linter_registry'
require 'liquid_lint/logger'
require 'liquid_lint/version'

# Load all filters (required by LiquidLint::Engine)
Dir[File.expand_path('liquid_lint/filters/*.rb', File.dirname(__FILE__))].sort.each do |file|
  require file
end

require 'liquid_lint/engine'
require 'liquid_lint/document'
require 'liquid_lint/capture_map'
require 'liquid_lint/sexp_visitor'
require 'liquid_lint/lint'
require 'liquid_lint/ruby_parser'
require 'liquid_lint/linter'
require 'liquid_lint/reporter'
require 'liquid_lint/report'
require 'liquid_lint/linter_selector'
require 'liquid_lint/runner'

# Load all matchers
require 'liquid_lint/matcher/base'
Dir[File.expand_path('liquid_lint/matcher/*.rb', File.dirname(__FILE__))].sort.each do |file|
  require file
end

# Load all linters
Dir[File.expand_path('liquid_lint/linter/*.rb', File.dirname(__FILE__))].sort.each do |file|
  require file
end

# Load all reporters
Dir[File.expand_path('liquid_lint/reporter/*.rb', File.dirname(__FILE__))].sort.each do |file|
  require file
end
