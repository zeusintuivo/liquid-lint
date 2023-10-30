# frozen_string_literal: true

require 'spec_helper'

describe 'Config comments' do
  context 'single file' do
    include_context 'linter'

    let(:described_class) { LiquidLint::Linter::TagCase }

    let(:liquid) { <<-LIQUID }
      IMG src="images/cat.gif"

      / liquid-lint:disable TagCase
      IMG src="images/cat.gif"
      / liquid-lint:enable TagCase

      IMG src="images/cat.gif"
    LIQUID

    it { should report_lint line: 1 }
    it { should_not report_lint line: 4 }
    it { should report_lint line: 7 }
  end

  context 'multiple files' do
    # We can't use the 'linter' shared context here because it assumes
    # that the linter is being run on a single file.

    let(:described_class) { LiquidLint::Linter::TagCase }

    let(:config) do
      LiquidLint::ConfigurationLoader.default_configuration
                                   .for_linter(described_class)
    end

    subject { described_class.new(config) }

    let(:first_file) { <<-LIQUID }
      IMG src="images/cat.gif"
    LIQUID

    let(:second_file) { <<-LIQUID }
      IMG src="images/cat.gif"

      / liquid-lint:disable TagCase
      IMG src="images/cat.gif"
      / liquid-lint:enable TagCase

      IMG src="images/cat.gif"
    LIQUID

    it 'handles the enable/disable config comment properly when reusing the linter' do
      first_document = LiquidLint::Document.new(normalize_indent(first_file), config: config)
      subject.run(first_document)

      expect(subject).to report_lint line: 1

      second_document = LiquidLint::Document.new(normalize_indent(second_file), config: config)
      subject.run(second_document)

      expect(subject).to report_lint line: 1
      expect(subject).to_not report_lint line: 4
      expect(subject).to report_lint line: 7
    end
  end
end
