# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::Zwsp do
  include_context 'linter'

  context 'when with ZWSP' do
    let(:liquid) { <<-LIQUID }
      | Hello ZWSP\u200b
    LIQUID

    it { should report_lint line: 1 }
  end

  context 'when without ZWSP' do
    let(:liquid) { <<-LIQUID }
      | Hello without ZWSP
    LIQUID

    it { should_not report_lint }
  end
end
