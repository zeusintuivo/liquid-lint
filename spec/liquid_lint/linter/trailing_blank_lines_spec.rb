# frozen_string_literal: true

require 'spec_helper'

describe LiquidLint::Linter::TrailingBlankLines do
  include_context 'linter'

  context 'when line does not have line feed' do
    let(:liquid) { '.style' }

    it { should report_lint line: 1 }
  end

  context 'when last line does not have line feed' do
    let(:liquid) { ".style\n  .other" }

    it { should report_lint line: 2 }
  end

  context 'when line contains multiple trailing newline' do
    let(:liquid) { ".style\n\n" }

    it { should report_lint line: 2 }
  end

  context 'when line contains trailing newline' do
    let(:liquid) { ".style\n" }

    it { should_not report_lint }
  end

  context 'when last line does not have line feed' do
    let(:liquid) { ".style\n  .other\n" }

    it { should_not report_lint }
  end

  context 'when source is empty' do
    let(:liquid) { '' }

    it { should_not report_lint }
  end
end
