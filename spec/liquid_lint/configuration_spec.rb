# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Configuration do
  let(:config) { LiquidLint::ConfigurationLoader.default_configuration }

  describe '#initialize' do
    let(:config) { described_class.new(hash) }
    subject { config }

    context 'with an empty hash' do
      let(:hash) { {} }

      it 'creates an empty `exclude` section' do
        subject['exclude'].should == []
      end

      it 'creates an empty `linters` section' do
        subject['linters'].should == {}
      end
    end

    context 'with a linter with single values in its `include`/`exclude` options' do
      let(:hash) do
        {
          'linters' => {
            'SomeLinter' => {
              'include' => '**/*.liquid',
              'exclude' => '**/*.ignore.liquid',
            },
          },
        }
      end

      it 'converts the `include` value into an array' do
        subject['linters']['SomeLinter']['include'].should == ['**/*.liquid']
      end

      it 'converts the `exclude` value into an array' do
        subject['linters']['SomeLinter']['exclude'].should == ['**/*.ignore.liquid']
      end
    end
  end

  describe '#for_linter' do
    subject { config.for_linter(linter) }

    context 'when linter is a Class' do
      let(:linter) { LiquidLint::Linter::LineLength }

      it 'returns the configuration for the relevant linter' do
        subject['max'].should == 80
      end
    end

    context 'when linter is a Linter' do
      let(:linter) { LiquidLint::Linter::LineLength.new(double) }

      it 'returns the configuration for the relevant linter' do
        subject['max'].should == 80
      end
    end
  end
end
