# frozen_string_literal: true

require 'liquid_lint'
require 'liquid_lint/options'

module LiquidLint
  # Command line application interface.
  class CLI # rubocop:disable Metrics/ClassLength
    # Exit codes
    # @see https://man.openbsd.org/sysexits.3
    EX_OK = 0
    EX_USAGE = 64
    EX_DATAERR = 65
    EX_NOINPUT = 67
    EX_SOFTWARE = 70
    EX_CONFIG = 78

    # Create a CLI that outputs to the specified logger.
    #
    # @param logger [LiquidLint::Logger]
    def initialize(logger)
      @log = logger
    end

    # Parses the given command-line arguments and executes appropriate logic
    # based on those arguments.
    #
    # @param args [Array<String>] command line arguments
    # @return [Integer] exit status code
    def run(args)
      options = LiquidLint::Options.new.parse(args)
      act_on_options(options)
    rescue StandardError => e
      handle_exception(e)
    end

    private

    attr_reader :log

    # Given the provided options, execute the appropriate command.
    #
    # @return [Integer] exit status code
    def act_on_options(options)
      log.color_enabled = options.fetch(:color, log.tty?)

      if options[:help]
        print_help(options)
        EX_OK
      elsif options[:version] || options[:verbose_version]
        print_version(options)
        EX_OK
      elsif options[:show_linters]
        print_available_linters
        EX_OK
      elsif options[:show_reporters]
        print_available_reporters
        EX_OK
      else
        scan_for_lints(options)
      end
    end

    # Outputs a message and returns an appropriate error code for the specified
    # exception.
    def handle_exception(exception)
      case exception
      when LiquidLint::Exceptions::ConfigurationError
        log.error exception.message
        EX_CONFIG
      when LiquidLint::Exceptions::InvalidCLIOption
        log.error exception.message
        log.log "Run `#{APP_NAME}` --help for usage documentation"
        EX_USAGE
      when LiquidLint::Exceptions::InvalidFilePath
        log.error exception.message
        EX_NOINPUT
      when LiquidLint::Exceptions::NoLintersError
        log.error exception.message
        EX_NOINPUT
      else
        print_unexpected_exception(exception)
        EX_SOFTWARE
      end
    end

    # Scans the files specified by the given options for lints.
    #
    # @return [Integer] exit status code
    def scan_for_lints(options)
      report = Runner.new.run(options)
      print_report(report, options)
      report.failed? ? EX_DATAERR : EX_OK
    end

    # Outputs a report of the linter run using the specified reporter.
    def print_report(report, options)
      reporter = options.fetch(:reporter,
                               LiquidLint::Reporter::DefaultReporter).new(log)
      reporter.display_report(report)
    end

    # Outputs a list of all currently available linters.
    def print_available_linters
      log.info 'Available linters:'

      linter_names = LiquidLint::LinterRegistry.linters.map do |linter|
        linter.name.split('::').last
      end

      linter_names.sort.each do |linter_name|
        log.log " - #{linter_name}"
      end
    end

    # Outputs a list of currently available reporters.
    def print_available_reporters
      log.info 'Available reporters:'

      reporter_names = LiquidLint::Reporter.descendants.map do |reporter|
        reporter.name.split('::').last.sub(/Reporter$/, '').downcase
      end

      reporter_names.sort.each do |reporter_name|
        log.log " - #{reporter_name}"
      end
    end

    # Outputs help documentation.
    def print_help(options)
      log.log options[:help]
    end

    # Outputs the application name and version.
    def print_version(options)
      log.log "#{LiquidLint::APP_NAME} #{LiquidLint::VERSION}"

      if options[:verbose_version]
        log.log "liquid #{Gem.loaded_specs['liquid'].version}"
        log.log "rubocop #{Gem.loaded_specs['rubocop'].version}"
        log.log RUBY_DESCRIPTION
      end
    end

    # Outputs the backtrace of an exception with instructions on how to report
    # the issue.
    def print_unexpected_exception(exception) # rubocop:disable Metrics/AbcSize
      log.bold_error exception.message
      log.error exception.backtrace.join("\n")
      log.warning 'Report this bug at ', false
      log.info LiquidLint::BUG_REPORT_URL
      log.newline
      log.success 'To help fix this issue, please include:'
      log.log '- The above stack trace'
      log.log '- Liquid-Lint version: ', false
      log.info LiquidLint::VERSION
      log.log '- RuboCop version: ', false
      log.info Gem.loaded_specs['rubocop'].version
      log.log '- Ruby version: ', false
      log.info RUBY_VERSION
    end
  end
end
