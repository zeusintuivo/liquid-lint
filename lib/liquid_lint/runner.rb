# frozen_string_literal: true

module LiquidLint
  # Responsible for running the applicable linters against the desired files.
  class Runner
    # Runs the appropriate linters against the desired files given the specified
    # options.
    #
    # @param [Hash] options
    # @option options :config_file [String] path of configuration file to load
    # @option options :config [LiquidLint::Configuration] configuration to use
    # @option options :excluded_files [Array<String>]
    # @option options :included_linters [Array<String>]
    # @option options :excluded_linters [Array<String>]
    # @return [LiquidLint::Report] a summary of all lints found
    def run(options = {})
      config = load_applicable_config(options)
      linter_selector = LiquidLint::LinterSelector.new(config, options)

      if options[:stdin_file_path].nil?
        files = extract_applicable_files(config, options)
        lints = files.map do |file|
          collect_lints(File.read(file), file, linter_selector, config)
        end.flatten
      else
        files = [options[:stdin_file_path]]
        lints = collect_lints($stdin.read, options[:stdin_file_path], linter_selector, config)
      end

      LiquidLint::Report.new(lints, files)
    end

    private

    # Returns the {LiquidLint::Configuration} that should be used given the
    # specified options.
    #
    # @param options [Hash]
    # @return [LiquidLint::Configuration]
    def load_applicable_config(options)
      if options[:config_file]
        LiquidLint::ConfigurationLoader.load_file(options[:config_file])
      elsif options[:config]
        options[:config]
      else
        LiquidLint::ConfigurationLoader.load_applicable_config
      end
    end

    # Runs all provided linters using the specified config against the given
    # file.
    #
    # @param file [String] path to file to lint
    # @param linter_selector [LiquidLint::LinterSelector]
    # @param config [LiquidLint::Configuration]
    def collect_lints(file_content, file_name, linter_selector, config)
      begin
        document = LiquidLint::Document.new(file_content, file: file_name, config: config)
      rescue LiquidLint::Exceptions::ParseError => e
        return [LiquidLint::Lint.new(nil, file_name, e.lineno, e.error, :error)]
      end

      linter_selector.linters_for_file(file_name).map do |linter|
        linter.run(document)
      end.flatten
    end

    # Returns the list of files that should be linted given the specified
    # configuration and options.
    #
    # @param config [LiquidLint::Configuration]
    # @param options [Hash]
    # @return [Array<String>]
    def extract_applicable_files(config, options)
      included_patterns = options[:files]
      excluded_patterns = config['exclude']
      excluded_patterns += options.fetch(:excluded_files, [])

      LiquidLint::FileFinder.new(config).find(included_patterns, excluded_patterns)
    end
  end
end
