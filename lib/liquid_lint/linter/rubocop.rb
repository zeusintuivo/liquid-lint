# frozen_string_literal: true

require 'liquid_lint/ruby_extractor'
require 'liquid_lint/ruby_extract_engine'
require 'rubocop'

module LiquidLint
  # Runs RuboCop on Ruby code extracted from Liquid templates.
  class Linter::RuboCop < Linter
    include LinterRegistry

    on_start do |_sexp|
      processed_sexp = LiquidLint::RubyExtractEngine.new.call(document.source)

      extractor = LiquidLint::RubyExtractor.new
      extracted_source = extractor.extract(processed_sexp)

      next if extracted_source.source.empty?

      find_lints(extracted_source.source, extracted_source.source_map)
    end

    private

    # Executes RuboCop against the given Ruby code and records the offenses as
    # lints.
    #
    # @param ruby [String] Ruby code
    # @param source_map [Hash] map of Ruby code line numbers to original line
    #   numbers in the template
    def find_lints(ruby, source_map)
      rubocop = ::RuboCop::CLI.new

      filename = document.file ? "#{document.file}.rb" : 'ruby_script.rb'

      with_ruby_from_stdin(ruby) do
        extract_lints_from_offenses(lint_file(rubocop, filename), source_map)
      end
    end

    # Defined so we can stub the results in tests
    #
    # @param rubocop [RuboCop::CLI]
    # @param file [String]
    # @return [Array<RuboCop::Cop::Offense>]
    def lint_file(rubocop, file)
      rubocop.run(rubocop_flags << file)
      OffenseCollector.offenses
    end

    # Aggregates RuboCop offenses and converts them to {LiquidLint::Lint}s
    # suitable for reporting.
    #
    # @param offenses [Array<RuboCop::Cop::Offense>]
    # @param source_map [Hash]
    def extract_lints_from_offenses(offenses, source_map)
      offenses.select { |offense| !config['ignored_cops'].include?(offense.cop_name) }
              .each do |offense|
        @lints << Lint.new(self,
                           document.file,
                           source_map[offense.line],
                           offense.message)
      end
    end

    # Returns flags that will be passed to RuboCop CLI.
    #
    # @return [Array<String>]
    def rubocop_flags
      flags = %w[--format LiquidLint::OffenseCollector]
      flags += ['--config', ENV['LIQUID_LINT_RUBOCOP_CONF']] if ENV['LIQUID_LINT_RUBOCOP_CONF']
      flags += ['--stdin']
      flags
    end

    # Overrides the global stdin to allow RuboCop to read Ruby code from it.
    #
    # @param ruby [String] the Ruby code to write to the overridden stdin
    # @param _block [Block] the block to perform with the overridden stdin
    # @return [void]
    def with_ruby_from_stdin(ruby, &_block)
      original_stdin = $stdin
      stdin = StringIO.new
      stdin.write(ruby)
      stdin.rewind
      $stdin = stdin
      yield
    ensure
      $stdin = original_stdin
    end
  end

  # Collects offenses detected by RuboCop.
  class OffenseCollector < ::RuboCop::Formatter::BaseFormatter
    class << self
      # List of offenses reported by RuboCop.
      attr_accessor :offenses
    end

    # Executed when RuboCop begins linting.
    #
    # @param _target_files [Array<String>]
    def started(_target_files)
      self.class.offenses = []
    end

    # Executed when a file has been scanned by RuboCop, adding the reported
    # offenses to our collection.
    #
    # @param _file [String]
    # @param offenses [Array<RuboCop::Cop::Offense>]
    def file_finished(_file, offenses)
      self.class.offenses += offenses
    end
  end
end
