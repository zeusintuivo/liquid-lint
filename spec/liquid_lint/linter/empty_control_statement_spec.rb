# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::EmptyControlStatement do
  include_context 'linter'

  context 'when a control statement contains code' do
    let(:liquid) { '- some_code' }

    it { should_not report_lint }
  end

  context 'when a control statement contains no code' do
    let(:liquid) { '-' }

    it { should report_lint line: 1 }
  end
end
