# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::Tab do
  include_context 'linter'

  context 'when a file contains tabs' do
    let(:liquid) { <<-LIQUID }
      .container
      \tp Hello World
    LIQUID

    it { should_not report_lint line: 1 }
    it { should report_lint line: 2 }
  end

  context 'when a file does not contain tabs' do
    let(:liquid) { <<-LIQUID }
      .container
        p Hello World
    LIQUID

    it { should_not report_lint }
  end
end
