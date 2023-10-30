# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Reporter::CheckstyleReporter do
  describe '#display_report' do
    let(:io) { StringIO.new }
    let(:output) { io.string }
    let(:logger) { LiquidLint::Logger.new(io) }
    let(:report) { LiquidLint::Report.new(lints, []) }
    let(:reporter) { described_class.new(logger) }

    subject { reporter.display_report(report) }

    context 'when there are no lints' do
      let(:lints) { [] }
      let(:files) { [] }

      it 'list of files is empty' do
        subject
        expect(output).to eq("<?xml version='1.0'?><checkstyle/>\n")
      end
    end

    context 'when there are lints' do
      let(:lint_data) do
        [
          {
            filename: 'some-filename.liquid',
            line: 502,
            description: 'Description of lint 1',
            severity: :warning,
          },
          {
            filename: 'other-filename.liquid',
            line: 724,
            description: 'Description of lint 2',
            severity: :error,
          },
        ]
      end

      let(:lints) do
        lint_data.map do |data|
          LiquidLint::Lint.new(
            nil,
            data[:filename],
            data[:line],
            data[:description],
            data[:severity]
          )
        end
      end

      it 'list of files contains files with offenses' do
        subject
        expect(output).to include("<file name='#{lint_data[0][:filename]}'>")
        expect(output).to include("<file name='#{lint_data[1][:filename]}'>")
        expect(output).to include(
          "<error line='#{lint_data[0][:line]}' "\
          "message='#{lint_data[0][:description]}' "\
          "severity='#{lint_data[0][:severity]}' "\
          "source='liquid-lint'/>"
        )
      end
    end
  end
end
