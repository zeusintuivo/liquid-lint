# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::EmptyLines do
  include_context 'linter'

  context 'when first line is blank' do
    let(:liquid) { "\n.style" }

    it { should report_lint line: 1 }
  end

  context '2 lines in a row are empty' do
    let(:liquid) { ".style\n\n\n.other" }

    it { should report_lint line: 3 }
  end

  context '3 lines in a row are empty' do
    let(:liquid) { ".style\n\n\n\n.other" }

    it { should report_lint line: 3 }
  end

  context 'line between instructions is empty' do
    let(:liquid) { ".style\n\n.other" }

    it { should_not report_lint }
  end
end
